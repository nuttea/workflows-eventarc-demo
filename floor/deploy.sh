#!/bin/bash

gcloud functions deploy floor \
  --runtime python39 \
  --entry-point=floor \ 
  --trigger-http \ 
  --no-allow-unauthenticated \
  --gen2 \
  --region asia-southeast1