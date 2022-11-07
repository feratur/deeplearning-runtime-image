#!/bin/bash
set -Eeuo pipefail

IMG_REPO="feratur/deeplearning-runtime"
IMG_VERSION="$1"

cd "$( dirname "${BASH_SOURCE[0]}" )"

echo "Starting Docker build (might take a while)..."
IMG_HASH="$( DOCKER_BUILDKIT=1 docker build -q . )"
echo "Image build successfully - $IMG_HASH"

IMG_TAG="${IMG_REPO}:${IMG_VERSION}"
docker tag "$IMG_HASH" "$IMG_TAG"
echo "Image tag: $IMG_TAG. Pushing to remote repository..."
docker push "$IMG_TAG"

echo "Image $IMG_TAG uploaded successfully!"
