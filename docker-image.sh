#!/bin/bash

DOCKER_ID=ljocha
IMAGE_REPO=chicken-and-egg

while (( "$#" )); do
  case "$1" in
    -u|--dockerid)
      if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
        DOCKER_ID=$2
        shift 2
      else
        echo "Error: Argument for $1 is missing" >&2
        exit 1
      fi
      ;;
  esac
done

IMAGE=$DOCKER_ID/$IMAGE_REPO
