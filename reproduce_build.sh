#!/bin/bash
source VARS
BASE_IMG_SHA256_CONTENT="b1b571c8536936879cba5467ecc71106ea01ae16a4eb2282c2db92d4c5db781c  shim-img-v15.8.tar.bz2"
echo "Clearing old base build image (if it exists)"
podman rmi evren/shim-img:v${SHIM_VERSION}
set -e
rm -rf work
mkdir -p work/output
echo "Getting the base build image"
wget -q https://support-files.evren.co/shim/shim-img-v${SHIM_VERSION}.tar.bz2
echo "Verifying image integrity"
echo "${BASE_IMG_SHA256_CONTENT}" | sha256sum -c
echo "Decompressing image"
bunzip2 shim-img-v${SHIM_VERSION}.tar.bz2
echo "Loading image in local registry"
podman load --quiet -i shim-img-v${SHIM_VERSION}.tar
echo "Cleaning up a bit"
rm -f shim-img-v${SHIM_VERSION}.tar
echo "Building shim"
podman build -t evren/shim:v${SHIM_VERSION} -f Containerfile-reproduce \
    --env SHIM_ARCHIVE_URL=${SHIM_ARCHIVE_URL} \
    --env SHIM_ARCHIVE_FILE=${SHIM_ARCHIVE_FILE} \
    --env SHIM_ARCHIVE_SHA256=${SHIM_ARCHIVE_SHA256} \
    --env VERIFY_ATTESTATION_SCRIPT_URL=${VERIFY_ATTESTATION_SCRIPT_URL} \
    --env PARSE_VERIFIED_ATTESTATION_SCRIPT_URL=${PARSE_VERIFIED_ATTESTATION_SCRIPT_URL} \
    --volume=`pwd`/work:/work:rw 2>&1 | tee 03-build-reproduce.log
echo "Reproduction built successfully completed. Please see build-reproduce.log"
