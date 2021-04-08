#!/usr/bin/env bash

docker build -t srfg/jenkins-master:latest .
docker push srfg/jenkins-master:latest