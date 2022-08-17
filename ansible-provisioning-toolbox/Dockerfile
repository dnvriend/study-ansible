FROM python:3-alpine

# dependencies for toolbox
RUN apk --update add bash git openssh openssl curl wget py-pip jq gcc musl-dev linux-headers libffi-dev
RUN pip install --upgrade pip && pip install --progress-bar=off awscli boto3 ansible

WORKDIR /toolbox
