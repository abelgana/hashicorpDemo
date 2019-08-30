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

RUN wget https://storage.googleapis.com/kubernetes-release/release/v1.13.10/bin/linux/amd64/kubectl \
    -P /usr/local/bin && \
    chmod +x /usr/local/bin/kubectl && \
    apk add py-pip gettext
