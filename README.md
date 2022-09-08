# Eventarc trigger Cloud Workflows Service chaining to Cloud Function and Cloud Run

In this sample, you will create Eventarc triggers to trigger from Cloud Storage and PubSub event, which will then trigger a workflow to orchestrate multiple Cloud Functions, Cloud Run and external services in a workflow.

## GCP Environment setup

Set PROJECT_ID, REGION

```sh
REGION=asia-southeast1

echo "Get the project id"
gcloud config set project "<YOUR-PROJECT_ID>"
PROJECT_ID=$(gcloud config get-value project)
```

Enable required services on the project

```sh
echo "Enable required services"
gcloud services enable \
  eventarc.googleapis.com \
  pubsub.googleapis.com \
  run.googleapis.com \
  functions.googleapis.com \
  workflows.googleapis.com
```

## Cloud Function - Random number

Inside [randomgen](randomgen) folder, deploy a function that generates a random number:

```sh
gcloud functions deploy randomgen \
    --gen2 \
    --runtime python39 \
    --trigger-http \
    --entry-point randomgen \
    --source . \
    --allow-unauthenticated
```

Test:

```sh
curl https://us-central1-workflows-atamel.cloudfunctions.net/randomgen
```

## Cloud Function - Multiply

Inside [multiply](multiply) folder, deploy a function that multiplies a given number:

```sh
gcloud functions deploy multiply \
    --gen2 \
    --runtime python39 \
    --trigger-http \
    --entry-point multiply \
    --source . \
    --allow-unauthenticated
```

Test:

```sh
curl -X POST https://us-central1-workflows-atamel.cloudfunctions.net/multiply \
    -H "content-type: application/json" \
    -d '{"input":5}'
```

## External Function - MathJS

For an external function, use [MathJS](https://api.mathjs.org/).

Test:

```sh
curl https://api.mathjs.org/v4/?expr=log(56)
```

## Cloud Run - Floor

Inside [floor](floor) folder, deploy an authenticated Cloud Run service that floors a number.

Build the container:

```sh
export SERVICE_NAME=floor
gcloud builds submit --tag gcr.io/${PROJECT_ID}/${SERVICE_NAME}
```

Deploy:

```sh
gcloud run deploy ${SERVICE_NAME} \
  --image gcr.io/${PROJECT_ID}/${SERVICE_NAME} \
  --platform managed \
  --no-allow-unauthenticated
```

Test:

```sh
curl -X POST https://floor-wvdg6hhtla-ew.a.run.app \
    -H "content-type: application/json" \
    -d '{"input": "6.86"}'
```

## Service account for Workflows

Create a service account for Workflows:

```sh
export WORKFLOW_SERVICE_ACCOUNT=workflows-sa
gcloud iam service-accounts create ${WORKFLOW_SERVICE_ACCOUNT}
```

Grant `run.invoker` role to the service account:

```sh
gcloud projects add-iam-policy-binding ${PROJECT_ID} \
    --member "serviceAccount:${WORKFLOW_SERVICE_ACCOUNT}@${PROJECT_ID}.iam.gserviceaccount.com" \
    --role "roles/run.invoker"
gcloud projects add-iam-policy-binding ${PROJECT_ID} \
    --member "serviceAccount:${WORKFLOW_SERVICE_ACCOUNT}@${PROJECT_ID}.iam.gserviceaccount.com" \
    --role "roles/cloudfunctions.invoker"
gcloud projects add-iam-policy-binding ${PROJECT_ID} \
    --member "serviceAccount:${WORKFLOW_SERVICE_ACCOUNT}@${PROJECT_ID}.iam.gserviceaccount.com" \
    --role "roles/logging.logWriter"
```

## Workflow

Deploy workflow:

```sh
WORKFLOW_NAME=event-payload-workflow
gcloud workflows deploy ${WORKFLOW_NAME} \
    --source=workflow.yaml \
    --service-account=${WORKFLOW_SERVICE_ACCOUNT}@${PROJECT_ID}.iam.gserviceaccount.com
```

## Trigger a Workflow with PubSub

Setup Eventarc with PubSub as a trigger source

```sh
EVENTARC_SERVICE_ACCOUNT=eventarc-workflows

echo "Create an Eventarc trigger to listen for events from a Pub/Sub topic and route to $WORKFLOW_NAME workflow"
TRIGGER_NAME=$WORKFLOW_NAME-pubsub
gcloud eventarc triggers create $TRIGGER_NAME \
  --location=$REGION \
  --destination-workflow=$WORKFLOW_NAME \
  --destination-workflow-location=$REGION \
  --event-filters="type=google.cloud.pubsub.topic.v1.messagePublished" \
  --service-account=$SERVICE_ACCOUNT@$PROJECT_ID.iam.gserviceaccount.com
```

Test trigger with manual publish pubsub message

```sh
echo "Get the id of the underlying topic"
TOPIC=$(basename $(gcloud eventarc triggers describe $TRIGGER_NAME --format='value(transport.pubsub.topic)' --location=$REGION))

echo "Publish a message to the topic: $TOPIC"
gcloud pubsub topics publish $TOPIC --message="Hello World"
```

## Trigger a Workflow with Cloud Storage

Setup Cloud Storage Bucket and Eventarc with Cloud Storage Event

```sh
echo "Grant the pubsub.publisher role to the Cloud Storage service account needed for Eventarc's Cloud Storage trigger"
SERVICE_ACCOUNT_STORAGE="$(gsutil kms serviceaccount -p $PROJECT_ID)"
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member serviceAccount:$SERVICE_ACCOUNT_STORAGE \
    --role roles/pubsub.publisher

echo "Create a Cloud Storage bucket"
BUCKET=$PROJECT_ID-bucket
gsutil mb -l $REGION gs://$BUCKET

echo "Create an Eventarc trigger to listen for events from a Cloud Storage bucket and route to $WORKFLOW_NAME workflow"
TRIGGER_NAME=$WORKFLOW_NAME-storage
gcloud eventarc triggers create $TRIGGER_NAME \
  --location=$REGION \
  --destination-workflow=$WORKFLOW_NAME \
  --destination-workflow-location=$REGION \
  --event-filters="type=google.cloud.storage.object.v1.finalized" \
  --event-filters="bucket=$BUCKET" \
  --service-account=$SERVICE_ACCOUNT@$PROJECT_ID.iam.gserviceaccount.com
```

Test trigger with manual upload a file to Cloud Storage Bucket

```sh
echo "Upload a file to the bucket: $BUCKET"
echo "Hello World" > random.txt
gsutil cp random.txt gs://$BUCKET/random.txt
```

-------

This is not an official Google product.