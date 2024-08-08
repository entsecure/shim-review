ARG SHIM_VERSION=15.8
FROM docker.io/fabricemarie/base:v${SHIM_VERSION}

ARG ATTEMPT_NO=1
ARG SHIM_ARCHIVE_URL=https://github.com/rhboot/shim/releases/download/15.8/shim-15.8.tar.bz2
ARG SHIM_ARCHIVE_FILE=shim-15.8.tar.bz2
ARG SHIM_ARCHIVE_SHA256=a79f0a9b89f3681ab384865b1a46ab3f79d88b11b4ca59aa040ab03fffae80a9
ARG VERIFY_ATTESTATION_SCRIPT_URL=https://raw.githubusercontent.com/GoogleCloudPlatform/python-docs-samples/main/kms/attestations/verify_attestation.py
ARG PARSE_VERIFIED_ATTESTATION_SCRIPT_URL=https://www.marvell.com/content/dam/marvell/en/public-collateral/security-solutions/parse_v2.py

ENV ATTEMPT_NO=${ATTEMPT_NO}
ENV SHIM_ARCHIVE_URL=${SHIM_ARCHIVE_URL}
ENV SHIM_ARCHIVE_FILE=${SHIM_ARCHIVE_FILE}
ENV SHIM_ARCHIVE_SHA256=${SHIM_ARCHIVE_SHA256}
ENV VERIFY_ATTESTATION_SCRIPT_URL=${VERIFY_ATTESTATION_SCRIPT_URL}
ENV PARSE_VERIFIED_ATTESTATION_SCRIPT_URL=${PARSE_VERIFIED_ATTESTATION_SCRIPT_URL}

RUN echo ${ATTEMPT_NO}
RUN wget --no-verbose ${SHIM_ARCHIVE_URL} \
        -O /root/rpmbuild/SOURCES/${SHIM_ARCHIVE_FILE} && \
    echo "${SHIM_ARCHIVE_SHA256} /root/rpmbuild/SOURCES/${SHIM_ARCHIVE_FILE}" | \
        sha256sum -c
RUN echo "Downloading ${VERIFY_ATTESTATION_SCRIPT_URL}" && \
    wget --no-verbose ${VERIFY_ATTESTATION_SCRIPT_URL} -O /verify_attestation.py && \
    chmod 755 /verify_attestation.py && \
    echo "Downloading ${PARSE_VERIFIED_ATTESTATION_SCRIPT_URL}" && \
    wget --no-verbose ${PARSE_VERIFIED_ATTESTATION_SCRIPT_URL} -O /parse_v2.py && \
    chmod 755 /parse_v2.py
COPY sbat.evren.csv evren_securebootca_cert.der evren_secureboot_signer_cert.der \
    shim.patches shim-find-debuginfo.sh patches/* evren_dbx.esl /root/rpmbuild/SOURCES/
COPY shim-unsigned-x64.spec /root/rpmbuild/SPECS/
COPY shimia32.efi shimx64.efi attestation attestation2 \
    entsecureca_trust_chain.pem signer2_trust_chain.pem verify_attestation.patch \
    do_review.sh /
RUN rpmdev-setuptree && mkdir -p /work/output/x86_64 && mkdir -p /work/output/ia32 && \
    rpmbuild -ba /root/rpmbuild/SPECS/shim-unsigned-x64.spec
RUN rpm -qa | tee /work/output/builder-packages.txt && \
    cd /var/tmp && \
    rpm2cpio /root/rpmbuild/RPMS/x86_64/shim-unsigned-ia32-*.x86_64.rpm | cpio -idmv && \
    rpm2cpio /root/rpmbuild/RPMS/x86_64/shim-unsigned-x64-*.x86_64.rpm | cpio -idmv && \
    cp ./usr/share/shim/*/x64/shimx64.efi /work/output/x86_64/ && \
    cp ./usr/share/shim/*/ia32/shimia32.efi /work/output/ia32/
RUN cd / && chmod 755 ./do_review.sh
RUN cd / && ./do_review.sh
