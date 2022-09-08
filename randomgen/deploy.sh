#!/bin/bash

gcloud functions deploy randomgen --runtime python38 --trigger-http --allow-unauthenticated --gen2 --region asia-southeast1