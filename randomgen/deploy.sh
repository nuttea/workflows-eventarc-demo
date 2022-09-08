#!/bin/bash

gcloud functions deploy randomgen --runtime nodejs16 --entry-point=randomgen --trigger-http --allow-unauthenticated --gen2 --region asia-southeast1