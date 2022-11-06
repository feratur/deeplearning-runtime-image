#!/bin/bash
set -e

if [[ -n "$S3_DATA_PATH" ]]; then
  echo "[`date -u +"%Y-%m-%dT%H:%M:%SZ"`] Downloading data from S3 storage..."
  SECONDS=0
  mkdir -p /data
  aws s3 cp "$S3_DATA_PATH" /data/ --recursive $S3_PARAMS
  echo "[`date -u +"%Y-%m-%dT%H:%M:%SZ"`] Files downloaded to /data directory; $SECONDS seconds elapsed."
fi

exec "$@"
