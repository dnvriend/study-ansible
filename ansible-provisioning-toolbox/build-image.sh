#!/bin/bash
source version.sh
source vars.sh
docker build -t $IMAGE_NAME:$VERSION .


