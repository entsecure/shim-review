#!/bin/bash
set -e
echo "Re-building shim and running review script" | tee 03-build-reproduce.log
docker build . 2>&1 | tee -a 03-build-reproduce.log
echo "Reproduction built successfully completed. Please see 03-build-reproduce.log"
