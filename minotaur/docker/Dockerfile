ARG FUNCTION_DIR="/var/task"

# compiles parts of lambda binaries
FROM python:3.8-buster as build-image

RUN apt-get update && \
  apt-get install -y \
  g++ \
  make \
  cmake \
  unzip \
  libcurl4-openssl-dev

ARG FUNCTION_DIR
RUN mkdir -p ${FUNCTION_DIR}

RUN pip install \
        --target ${FUNCTION_DIR} \
        awslambdaric


# use python3.8 runtime
FROM python:3.8-slim

ARG FUNCTION_DIR
WORKDIR ${FUNCTION_DIR}

COPY --from=build-image ${FUNCTION_DIR} ${FUNCTION_DIR}

RUN apt-get update \
 && apt-get -y install --no-install-recommends \
    openssh-client coreutils wget curl \
    nmap jq \
 && apt-get -yq clean \
 && rm -rf /var/lib/apt/lists/*

COPY app/* ${FUNCTION_DIR}/

ARG CONTAINER_TAG
ENV CONTAINER_TAG=${CONTAINER_TAG:-0.0}

ENTRYPOINT [ "/usr/local/bin/python", "-m", "awslambdaric" ]
CMD [ "app.handler" ]
