ARG BUILD_ARCH
FROM ${BUILD_ARCH}/python:3.7-alpine as build
ARG BUILD_ARCH
ARG FRIENDLY_ARCH

# Multi-arch
COPY etc/qemu-arm-static /usr/bin/
COPY etc/qemu-aarch64-static /usr/bin/

RUN apk update && apk add --no-cache build-base portaudio-dev swig
RUN python3 -m venv /venv

COPY requirements.txt /

RUN grep '^rhasspy-' /requirements.txt | \
    sed -e 's|=.\+|/archive/master.tar.gz|' | \
    sed 's|^|https://github.com/rhasspy/|' \
    > /requirements_rhasspy.txt

RUN /venv/bin/pip install --upgrade pip
RUN /venv/bin/pip install https://github.com/synesthesiam/pocketsphinx-python/releases/download/v1.0/pocketsphinx-python.tar.gz
RUN /venv/bin/pip install -r /requirements_rhasspy.txt
RUN /venv/bin/pip install -r /requirements.txt

# -----------------------------------------------------------------------------

ARG BUILD_ARCH
FROM ${BUILD_ARCH}/python:3.7-alpine
ARG BUILD_ARCH
ARG FRIENDLY_ARCH

# Multi-arch
COPY etc/qemu-arm-static /usr/bin/
COPY etc/qemu-aarch64-static /usr/bin/

RUN apk update && apk add --no-cache portaudio

COPY --from=build /venv/ /venv/

COPY rhasspywake_pocketsphinx_hermes/ /rhasspywake_pocketsphinx_hermes/
WORKDIR /

ENTRYPOINT ["/venv/bin/python3", "-m", "rhasspywake_pocketsphinx_hermes"]
