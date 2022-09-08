#!/bin/bash

gcloud functions deploy multiply --runtime python38 --entry-point=multiply --trigger-http --allow-unauthenticated --gen2 --region asia-southeast1