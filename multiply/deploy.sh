#!/bin/bash

gcloud functions deploy multiply --runtime python39 --entry-point=multiply --trigger-http --allow-unauthenticated --gen2 --region asia-southeast1