#!/bin/bash
set -e
for OLD_CERT in `/usr/bin/ls revoked-certs/*.pem`; do
    echo "Getting esl hash for certificate $OLD_CERT"
    cert-to-efi-hash-list \
      -s 512 \
      ${OLD_CERT} \
      ${OLD_CERT}.esl
done
echo "Updating Evren DBX list"
cat revoked-certs/*.esl > evren_dbx.esl
echo "Successfully updated evren_dbx.esl"
