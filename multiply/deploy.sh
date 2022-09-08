#!/bin/bash

gcloud functions deploy multiply --runtime python38 --trigger-http --allow-unauthenticated --gen2 --region asia-southeast1