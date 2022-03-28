#! /bin/bash

set -e

help() {
  cat <<EOF
Usage: ./scripts/update-image-tags.sh <APP> <ENV> <IMAGE_NAME> <IMAGE_TAG>
EOF
    exit 1
}

APP=$1
ENV=$2
IMAGE_NAME=$3
IMAGE_TAG=$4

[ $# = 4 ] || help 

APP_DIR=$APP/overlays/$ENV

cd $APP_DIR
kustomize edit set image $IMAGE_NAME:$IMAGE_TAG

git add .
git commit -m "[$APP] Deploy latest build" -m "image tag $IMAGE_TAG"
git push