#!/bin/bash

export SERVICE_NAME=floor
gcloud builds submit --tag gcr.io/${PROJECT_ID}/${SERVICE_NAME}
```

Deploy:

```sh
gcloud run deploy ${SERVICE_NAME} \
  --image gcr.io/${PROJECT_ID}/${SERVICE_NAME} \
  --platform managed \
  --no-allow-unauthenticated