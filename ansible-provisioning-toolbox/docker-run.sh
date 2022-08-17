#!/bin/bash
source version.sh
source vars.sh
docker run -it -v $PWD/..:/study-ansible -v $HOME/.aws:/root/.aws $IMAGE_NAME:$VERSION /bin/bash

