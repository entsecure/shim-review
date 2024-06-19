#!/bin/bash
source VARS
BASE_IMG_SHA256_CONTENT="e797856a149d77a3a18ae39b973e1e4109bc1562ffbf85e8b1e8755de7184b7a  docker-shim-img-v15.8.tar.bz2"
echo "Clearing old base build image (if it exists)"
docker rmi evren/shim-img:v${SHIM_VERSION}
set -e
rm -rf work docker-shim-img-v${SHIM_VERSION}.tar docker-shim-img-v${SHIM_VERSION}.tar.bz2
mkdir -p work/output
echo "Getting the base build image"
wget -q https://support-files.evren.co/shim/docker-shim-img-v${SHIM_VERSION}.tar.bz2
echo "Verifying image integrity"
echo "${BASE_IMG_SHA256_CONTENT}" | sha256sum -c
echo "Decompressing image"
bunzip2 docker-shim-img-v${SHIM_VERSION}.tar.bz2
echo "Loading image in local registry"
docker load -i docker-shim-img-v${SHIM_VERSION}.tar
echo "Re-building shim" | tee 03-build-reproduce.log
docker build -t evren/shim:v${SHIM_VERSION} -f Dockerfile-reproduce \
    --build-arg SHIM_VERSION=${SHIM_VERSION} \
    --build-arg SHIM_ARCHIVE_URL=${SHIM_ARCHIVE_URL} \
    --build-arg SHIM_ARCHIVE_FILE=${SHIM_ARCHIVE_FILE} \
    --build-arg SHIM_ARCHIVE_SHA256=${SHIM_ARCHIVE_SHA256} \
    --build-arg VERIFY_ATTESTATION_SCRIPT_URL=${VERIFY_ATTESTATION_SCRIPT_URL} \
    --build-arg PARSE_VERIFIED_ATTESTATION_SCRIPT_URL=${PARSE_VERIFIED_ATTESTATION_SCRIPT_URL} \
    . 2>&1 | tee -a 03-build-reproduce.log

echo -e "\nRunning review script\n" tee -a 03-build-reproduce.log

docker run --rm \
    --volume=`pwd`/work:/work2:rw \
    evren/shim:v${SHIM_VERSION} 2>&1 | tee -a 03-build-reproduce.log | tee -a work/output/review.txt

echo "Reproduction built successfully completed. Please see 03-build-reproduce.log"
