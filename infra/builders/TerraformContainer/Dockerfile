FROM hashicorp/terraform

RUN \
  apk update && \
  apk add bash py-pip && \
  apk add --virtual=build gcc libffi-dev musl-dev openssl-dev python-dev make && \
  pip --no-cache-dir install -U pip && \
  pip --no-cache-dir install azure-cli && \
  apk del --purge build

RUN apk add --update \
    python \
    build-base && \
    pip install awscli --upgrade --user && \
    apk --purge -v del py-pip && \
    rm -rf /var/cache/apk/*
