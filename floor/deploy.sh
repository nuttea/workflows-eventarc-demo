#!/bin/bash

export SERVICE_NAME=floor
gcloud run deploy ${SERVICE_NAME} \
  --source . \
  --platform managed \
  --no-allow-unauthenticated