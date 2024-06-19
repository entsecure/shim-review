#!/bin/bash
set -e
echo "Patching verity_attestation.py to ensure it exists with 1 on error"
pushd /
patch --verbose -p0 < verify_attestation.patch
popd

# compare the built and reproduced shims
echo "::review shims builds are repoduced -- start"
echo "Comparing prebuilt and rebuilt shimia32.efi"
cmp /var/tmp/usr/share/shim/*/ia32/shimia32.efi /shimia32.efi
echo "prebuilt and rebuilt shimia32.efi are the same"
echo "Comparing prebuilt and rebuilt shimx64.efi"
cmp /var/tmp/usr/share/shim/*/x64/shimx64.efi  /shimx64.efi
echo "prebuilt and rebuilt shimx64.efi are the same"
echo -e "::review shims builds are repoduced -- end\n\n"

echo "::review Evren SecureBoot CA and Evren SecureBoot Signer attestations -- start"
# Validate Google Cloud HSM attestation (that the Evren CA key have been generated within the HSM)
# convert the evren CA cert to PEM
openssl x509 -inform DER -outform PEM \
    -in /root/rpmbuild/SOURCES/evren_securebootca_cert.der \
    -out /evren_securebootca_cert.pem

# more info at https://cloud.google.com/kms/docs/attest-key
# verify the attestation signature
echo "Verifying FIPS-140-2 HSM attestation file validity (Evren SecureBoot CA)"
python3 /verify_attestation.py /attestation /entsecureca_trust_chain.pem
echo "FIPS-140-2 HSM attestation file for Evren SecureBoot CA is valid"

# more info at
# https://www.marvell.com/products/security-solutions/nitrox-hs-adapters/software-key-attestation.html#VerifyPubKey
# parse the attestation to show the attribute OBJ_ATTR_SENSITIVE (only/always true for keys generated on HSM)
# the first match is for the public key, the second match is the one we care about for the secret key
# 0x0103   OBJ_ATTR_SENSITIVE   Always true for keys generated on HSM.
echo "Ensuring FIPS-140-2 attestation for Evren SecureBoot CA has OBJ_ATTR_SENSITIVE set"
echo "0x0103: b'01'" > /expected_flag
python3 /parse_v2.py /attestation | grep 0x0103 | tail -n 1 > /actual_flag
cmp /expected_flag /actual_flag
echo "FIPS-140-2 attestation for Evren SecureBoot CA contains OBJ_ATTR_SENSITIVE (correct)"

# perform attestation verification for Evren Boot Signer 1 key too
openssl x509 -inform DER -outform PEM \
    -in /root/rpmbuild/SOURCES/evren_secureboot_signer_cert.der \
    -out /evren_secureboot_signer_cert.pem
echo "Verifying FIPS-140-2 HSM attestation file validity (Evren SecureBoot Signer1)"
python3 /verify_attestation.py /attestation2 /signer1_trust_chain.pem
echo "FIPS-140-2 HSM attestation file for Evren SecureBoot Signer1 is valid"
echo "Ensuring FIPS-140-2 attestation for Evren SecureBoot Signer1 has OBJ_ATTR_SENSITIVE set"
echo "0x0103: b'01'" > /expected_flag
python3 /parse_v2.py /attestation2 | grep 0x0103 | tail -n 1 > /actual_flag
cmp /expected_flag /actual_flag
echo "FIPS-140-2 attestation for Evren SecureBoot Signer1 contains OBJ_ATTR_SENSITIVE (correct)"
echo -e "::review Evren SecureBoot CA and Evren SecureBoot Signer attestations -- end\n\n"

echo "::review certificate -- start"
openssl x509 -in /root/rpmbuild/SOURCES/evren_securebootca_cert.der -inform der -noout -text
openssl x509 -in /root/rpmbuild/SOURCES/evren_secureboot_signer_cert.der -inform der -noout -text
echo -e "::review certificate -- end\n\n"

echo "::review sbatlevels -- start"
for name in $(find /work/output/ -type f -name "shim*.efi"); do
    objdump -j .sbat -s $name
done
echo -e "::review sbatlevels -- end\n\n"

echo "::review alignment -- start"
for name in $(find /work/output/ -type f -name "shim*.efi"); do
    echo "$name:"
    objdump -x $name | grep -E 'SectionAlignment|DllCharacteristics'
done
echo -e "::review alignment-end\n\n"

set +e
echo "::review edk2-validate -- start"
for name in $(find /work/output/ -type f -name "shim*.efi"); do
    echo -e "$name:\nNXcompat:";
    python3 /usr/local/lib/python*/site-packages/edk2toolext/image_validation.py -i \
        $name --get-nx-compat;
    echo  "Regular validation test:";
    python3 /usr/local/lib/python*/site-packages/edk2toolext/image_validation.py -i \
        $name --profile APP;
done
echo -e "::review edk2-validate -- end\n\n"
set -e

echo "::review hash -- start"
for name in $(find /work/output/ -type f -name "shim*.efi"); do sha256sum $name; done
echo -e "::review hash -- end\n\n"

echo "::review authenticode -- start"
for name in $(find /work/output/ -type f -name "shim*.efi"); do pesign -h -P -i $name; done
echo -e "::review authenticode -- end\n\n"

echo "::review objdump -- start"
for name in $(find /work/output/ -type f -name "shim*.efi"); do objdump -h $name; done
echo -e "::review objdump -- end\n\n"

echo "Copying all build files from container to user's work directory"
/usr/bin/cp -ar /work/* /work2

echo -e "review complete. Please check work/output/review.txt\n\n"
