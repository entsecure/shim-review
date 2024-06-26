This repo is for review of requests for signing shim. To create a request for review:

- clone this repo (preferably fork it)
- edit the template below
- add the shim.efi to be signed
- add build logs
- add any additional binaries/certificates/SHA256 hashes that may be needed
- commit all of that
- tag it with a tag of the form "myorg-shim-arch-YYYYMMDD"
- push it to GitHub
- file an issue at https://github.com/rhboot/shim-review/issues with a link to your tag
- approval is ready when the "accepted" label is added to your issue

Note that we really only have experience with using GRUB2 or systemd-boot on Linux, so
asking us to endorse anything else for signing is going to require some convincing on
your part.

Hint: check the [docs](./docs/) directory in this repo for guidance on submission and getting your shim signed.

Here's the template:

*******************************************************************************
### What organization or people are asking to have this signed?
*******************************************************************************
Entsecure South East Asia Pte Ltd

*******************************************************************************
### What product or service is this for?
*******************************************************************************
Evren OS (https://evren.co/): a centrally managed secure desktop operating system for the enterprise
(based heavily on Fedora architecture and base packages)

*******************************************************************************
### What's the justification that this really does need to be signed for the whole world to be able to boot it?
*******************************************************************************
Entsecure customers need to deploy EvrenOS with Secure Boot enabled.
The customers are seeking a more secure managed desktop OS solution and want to
use secure boot. EvrenOS is deployed in financial, gov and industrial organizations
that require secure boot.

*******************************************************************************
### Why are you unable to reuse shim from another distro that is already signed?
*******************************************************************************
Entsecure wants to employ Secure Boot for building a trusted operating system
from the ground up: from Shim, GRUB, kernel to kernel modules and TPM backed
full disk encryption keys.

Entsecure CA is used to sign Entsecure BootSigner certificate which is used to sign
custom kernels and network drivers, and as such needs a signed shim with our
certificate so that we can sign the drivers to allow users to keep Secure Boot on.

*******************************************************************************
### Who is the primary contact for security updates, etc.?
The security contacts need to be verified before the shim can be accepted. For subsequent requests, contact verification is only necessary if the security contacts or their PGP keys have changed since the last successful verification.

An authorized reviewer will initiate contact verification by sending each security contact a PGP-encrypted email containing random words.
You will be asked to post the contents of these mails in your `shim-review` issue to prove ownership of the email addresses and PGP keys.
*******************************************************************************
- Name: Fabrice A. Marie
- Position: CTO
- Email address: fabrice@evren.co
- PGP key fingerprint: [1F75 D13E BDA3 77D8 DFC6  F6D6 DB5C 8B72 5B71 46CC](https://keyserver.ubuntu.com/pks/lookup?op=vindex&search=0xdb5c8b725b7146cc)

(Key should be signed by the other security contacts, pushed to a keyserver
like keyserver.ubuntu.com, and preferably have signatures that are reasonably
well known in the Linux community.)

*******************************************************************************
### Who is the secondary contact for security updates, etc.?
*******************************************************************************
- Name: Kean Tan
- Position: Technology Lead
- Email address: kean.tan@evren.co
- PGP key fingerprint: [8C1E A555 9448 D7BB 519F  E258 7595 CDBA FDBF 89BF](https://keyserver.ubuntu.com/pks/lookup?op=vindex&search=0x7595cdbafdbf89bf)

(Key should be signed by the other security contacts, pushed to a keyserver
like keyserver.ubuntu.com, and preferably have signatures that are reasonably
well known in the Linux community.)

*******************************************************************************
### Were these binaries created from the 15.8 shim release tar?
Please create your shim binaries starting with the 15.8 shim release tar file: https://github.com/rhboot/shim/releases/download/15.8/shim-15.8.tar.bz2

This matches https://github.com/rhboot/shim/releases/tag/15.8 and contains the appropriate gnu-efi source.

Make sure the tarball is correct by verifying your download's checksum with the following ones:

```
a9452c2e6fafe4e1b87ab2e1cac9ec00  shim-15.8.tar.bz2
cdec924ca437a4509dcb178396996ddf92c11183  shim-15.8.tar.bz2
a79f0a9b89f3681ab384865b1a46ab3f79d88b11b4ca59aa040ab03fffae80a9  shim-15.8.tar.bz2
30b3390ae935121ea6fe728d8f59d37ded7b918ad81bea06e213464298b4bdabbca881b30817965bd397facc596db1ad0b8462a84c87896ce6c1204b19371cd1  shim-15.8.tar.bz2
```

Make sure that you've verified that your build process uses that file as a source of truth (excluding external patches) and its checksum matches. Furthermore, there's [a detached signature as well](https://github.com/rhboot/shim/releases/download/15.8/shim-15.8.tar.bz2.asc) - check with the public key that has the fingerprint `8107B101A432AAC9FE8E547CA348D61BC2713E9F` that the tarball is authentic. Once you're sure, please confirm this here with a simple *yes*.

A short guide on verifying public keys and signatures should be available in the [docs](./docs/) directory.
*******************************************************************************
The binary is created from Fedora-39 shim-unsigned-15.8-2, itself
pulling the official 15.8 shim release.

*******************************************************************************
### URL for a repo that contains the exact code which was built to result in your binary:
Hint: If you attach all the patches and modifications that are being used to your application, you can point to the URL of your application here (*`https://github.com/YOUR_ORGANIZATION/shim-review`*).

You can also point to your custom git servers, where the code is hosted.
*******************************************************************************
https://github.com/entsecure/shim

*******************************************************************************
### What patches are being applied and why:
Mention all the external patches and build process modifications, which are used during your building process, that make your shim binary be the exact one that you posted as part of this application.
*******************************************************************************
No patches have been applied. Only Entsecure's CA key embedding.

*******************************************************************************
### Do you have the NX bit set in your shim? If so, is your entire boot stack NX-compatible and what testing have you done to ensure such compatibility?

See https://techcommunity.microsoft.com/t5/hardware-dev-center/nx-exception-for-shim-community/ba-p/3976522 for more details on the signing of shim without NX bit.
*******************************************************************************
NX bit is disabled for now until the entire Fedora boot stack become compatible.

*******************************************************************************
### What exact implementation of Secure Boot in GRUB2 do you have? (Either Upstream GRUB2 shim_lock verifier or Downstream RHEL/Fedora/Debian/Canonical-like implementation)
Skip this, if you're not using GRUB2.
*******************************************************************************
Downstream Fedora.

*******************************************************************************
### Do you have fixes for all the following GRUB2 CVEs applied?
**Skip this, if you're not using GRUB2, otherwise make sure these are present and confirm with _yes_.**

* 2020 July - BootHole
  * Details: https://lists.gnu.org/archive/html/grub-devel/2020-07/msg00034.html
  * CVE-2020-10713
  * CVE-2020-14308
  * CVE-2020-14309
  * CVE-2020-14310
  * CVE-2020-14311
  * CVE-2020-15705
  * CVE-2020-15706
  * CVE-2020-15707
* March 2021
  * Details: https://lists.gnu.org/archive/html/grub-devel/2021-03/msg00007.html
  * CVE-2020-14372
  * CVE-2020-25632
  * CVE-2020-25647
  * CVE-2020-27749
  * CVE-2020-27779
  * CVE-2021-3418 (if you are shipping the shim_lock module)
  * CVE-2021-20225
  * CVE-2021-20233
* June 2022
  * Details: https://lists.gnu.org/archive/html/grub-devel/2022-06/msg00035.html, SBAT increase to 2
  * CVE-2021-3695
  * CVE-2021-3696
  * CVE-2021-3697
  * CVE-2022-28733
  * CVE-2022-28734
  * CVE-2022-28735
  * CVE-2022-28736
  * CVE-2022-28737
* November 2022
  * Details: https://lists.gnu.org/archive/html/grub-devel/2022-11/msg00059.html, SBAT increase to 3
  * CVE-2022-2601
  * CVE-2022-3775
* October 2023 - NTFS vulnerabilities
  * Details: https://lists.gnu.org/archive/html/grub-devel/2023-10/msg00028.html, SBAT increase to 4
  * CVE-2023-4693
  * CVE-2023-4692
*******************************************************************************
The current builds contain the grub,3 fixes but not the NTFS fixes,
but we don't build in the NTFS modules in our signed image (our grub2 source RPM is Fedora
grub2 source RPM but signed by our keys).

*******************************************************************************
### If shim is loading GRUB2 bootloader, and if these fixes have been applied, is the upstream global SBAT generation in your GRUB2 binary set to 4?
Skip this, if you're not using GRUB2, otherwise do you have an entry in your GRUB2 binary similar to:  
`grub,4,Free Software Foundation,grub,GRUB_UPSTREAM_VERSION,https://www.gnu.org/software/grub/`?
*******************************************************************************
No, it's grub,3.

*******************************************************************************
### Were old shims hashes provided to Microsoft for verification and to be added to future DBX updates?
### Does your new chain of trust disallow booting old GRUB2 builds affected by the CVEs?
If you had no previous signed shim, say so here. Otherwise a simple _yes_ will do.
*******************************************************************************
This is our first submission.

*******************************************************************************
### If your boot chain of trust includes a Linux kernel:
### Is upstream commit [1957a85b0032a81e6482ca4aab883643b8dae06e "efi: Restrict efivar_ssdt_load when the kernel is locked down"](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=1957a85b0032a81e6482ca4aab883643b8dae06e) applied?
### Is upstream commit [75b0cea7bf307f362057cc778efe89af4c615354 "ACPI: configfs: Disallow loading ACPI tables when locked down"](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=75b0cea7bf307f362057cc778efe89af4c615354) applied?
### Is upstream commit [eadb2f47a3ced5c64b23b90fd2a3463f63726066 "lockdown: also lock down previous kgdb use"](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=eadb2f47a3ced5c64b23b90fd2a3463f63726066) applied?
Hint: upstream kernels should have all these applied, but if you ship your own heavily-modified older kernel version, that is being maintained separately from upstream, this may not be the case.  
If you are shipping an older kernel, double-check your sources; maybe you do not have all the patches, but ship a configuration, that does not expose the issue(s).
*******************************************************************************
All of the appropriate commits are present.

The configuration setting CONFIG_EFI_CUSTOM_SSDT_OVERLAYS is enabled, but since
1957a85b0032a81e6482ca4aab883643b8dae06e is present,
this is disabled when lockdown is on, as it is when Secure Boot is enabled.

*******************************************************************************
### Do you build your signed kernel with additional local patches? What do they do?
*******************************************************************************
We use unmodified Fedora upstream kernels. We provide additional out of tree
kernel drivers for WiFi cards (lots of RTL cards) that need to be signed too.

*******************************************************************************
### Do you use an ephemeral key for signing kernel modules?
### If not, please describe how you ensure that one kernel build does not load modules built for another kernel.
*******************************************************************************
yes.

*******************************************************************************
### If you use vendor_db functionality of providing multiple certificates and/or hashes please briefly describe your certificate setup.
### If there are allow-listed hashes please provide exact binaries for which hashes are created via file sharing service, available in public with anonymous access for verification.
*******************************************************************************
No, We don't use vendor_db functionality

*******************************************************************************
### If you are re-using the CA certificate from your last shim binary, you will need to add the hashes of the previous GRUB2 binaries exposed to the CVEs mentioned earlier to vendor_dbx in shim. Please describe your strategy.
This ensures that your new shim+GRUB2 can no longer chainload those older GRUB2 binaries with issues.

If this is your first application or you're using a new CA certificate, please say so here.
*******************************************************************************
This is our first shim submission.

*******************************************************************************
### Is the Dockerfile in your repository the recipe for reproducing the building of your shim binary?
A reviewer should always be able to run `docker build .` to get the exact binary you attached in your application.

Hint: Prefer using *frozen* packages for your toolchain, since an update to GCC, binutils, gnu-efi may result in building a shim binary with a different checksum.

If your shim binaries can't be reproduced using the provided Dockerfile, please explain why that's the case, what the differences would be and what build environment (OS and toolchain) is being used to reproduce this build? In this case please write a detailed guide, how to setup this build environment from scratch.
*******************************************************************************
The build uses `podman` containers. To reproduce the build:

- run `./reproduce_build.sh` as a regular user, it will use docker build + run to reproduce the build
    - this will create a new log file called `03-build-reproduce.log`

*******************************************************************************
### Which files in this repo are the logs for your build?
This should include logs for creating the buildroots, applying patches, doing the build, creating the archives, etc.
*******************************************************************************

- [01-build-base-build-img.log](01-build-base-build-img.log): logs for building the base podman image.
- [02-shim-build.log](02-shim-build.log): logs for building the shim (using the base image created in step 1)

*******************************************************************************
### What changes were made in the distro's secure boot chain since your SHIM was last signed?
For example, signing new kernel's variants, UKI, systemd-boot, new certs, new CA, etc..

Skip this, if this is your first application for having shim signed.
*******************************************************************************
This is our first submission.

*******************************************************************************
### What is the SHA256 hash of your final shim binary?
*******************************************************************************

```shell
sha256sum shim*.efi
```

```
38aae1b3bb9c31bd2c373071a88c19c46790087db680994f1110e025ca512b8c  shimia32.efi
83b2eca6a857b1c0a1c2190c5f48992646211faa8c63b1cebd759fe99bee7780  shimx64.efi
```

*******************************************************************************
### How do you manage and protect the keys used in your shim?
Describe the security strategy that is used for key protection. This can range from using hardware tokens like HSMs or Smartcards, air-gapped vaults, physical safes to other good practices.
*******************************************************************************
Our setup includes a rootCA (`evren_securebootca_cert.der`) and a Boot Signer cert
(`evren_secureboot_signer_cert.der`) signed by our rootCA.

Both have their keys generated and locked in Google Cloud HSM (attestation attached).

Nobody currently has permissions to access the rootCA keys now that the signer cert
has been signed by the root CA: permission have been revoked immediaately after
signature of the Boot Signer CSR.

The signer cert key is only accessible automatically on GitHub action on 4 private repos:
- kernel, grub, memtest86+v7, fwupd-efi
- Google cloud applicative user key rotated every 3 months, saved as GitHub Action secret.
- 2 approvals required to merge into master branch (triggering the build+signature process)
- signed commits enforced, 2FA enforced.
- Access/operations are audited (company is SOC2 and ISO27k certified)

*******************************************************************************
### Do you use EV certificates as embedded certificates in the shim?
A _yes_ or _no_ will do. There's no penalty for the latter.
*******************************************************************************
No.

*******************************************************************************
### Do you add a vendor-specific SBAT entry to the SBAT section in each binary that supports SBAT metadata ( GRUB2, fwupd, fwupdate, systemd-boot, systemd-stub, shim + all child shim binaries )?
### Please provide the exact SBAT entries for all binaries you are booting directly through shim.
Hint: The history of SBAT and more information on how it works can be found [here](https://github.com/rhboot/shim/blob/main/SBAT.md). That document is large, so for just some examples check out [SBAT.example.md](https://github.com/rhboot/shim/blob/main/SBAT.example.md)

If you are using a downstream implementation of GRUB2 (e.g. from Fedora or Debian), make sure you have their SBAT entries preserved and that you **append** your own (don't replace theirs) to simplify revocation.

**Remember to post the entries of all the binaries. Apart from your bootloader, you may also be shipping e.g. a firmware updater, which will also have these.**

Hint: run `objcopy --only-section .sbat -O binary YOUR_EFI_BINARY /dev/stdout` to get these entries. Paste them here. Preferably surround each listing with three backticks (\`\`\`), so they render well.
*******************************************************************************

**Shim**
```
objcopy --only-section .sbat -O binary shimx64.efi /dev/stdout
```

```
sbat,1,SBAT Version,sbat,1,https://github.com/rhboot/shim/blob/main/SBAT.md
shim,4,UEFI shim,shim,1,https://github.com/rhboot/shim
shim.evren,1,Evren,shim,15.8,security@evren.co
```

**Grub2**
```shell
objcopy --only-section .sbat -O binary /boot/efi/EFI/fedora/grubx64.efi /dev/stdout 
```

```
sbat,1,SBAT Version,sbat,1,https://github.com/rhboot/shim/blob/main/SBAT.md
grub,3,Free Software Foundation,grub,2.06,https//www.gnu.org/software/grub/
grub.rh,2,Red Hat,grub2,2.06-122.ev39,mailto:secalert@redhat.com
grub.evren,1,Evren,grub2,2.06-122.ev39,mailto:security@evren.co
```

**fwupd-efi**
```shell
objcopy --only-section .sbat -O binary /usr/libexec/fwupd/efi/fwupdx64.efi /dev/stdout
```

```
sbat,1,UEFI shim,sbat,1,https://github.com/rhboot/shim/blob/main/SBAT.md
fwupd-efi,1,Firmware update daemon,fwupd-efi,1.6,https://github.com/fwupd/fwupd-efi
fwupd-efi.evren,1,EvrenOS,fwupd-efi,1.6-2,security@evren.co
```

**memtest86+v7**
```shell
objcopy --only-section .sbat -O binary /boot/memtest.efi /dev/stdout
```

```
sbat,1,SBAT Version,sbat,1,https://github.com/rhboot/shim/blob/main/SBAT.md
memtest86+,1,Memtest86+,6.0,https://github.com/memtest86plus
memtest86+.evren,1,Memtest86+,6.0,mailto:security@evren.co
```

*******************************************************************************
### If shim is loading GRUB2 bootloader, which modules are built into your signed GRUB2 image?
Skip this, if you're not using GRUB2.

Hint: this is about those modules that are in the binary itself, not the `.mod` files in your filesystem.
*******************************************************************************
We use the latest fedora-39 grub2 RPM, modified to sign with our cert, no other modification made.

```
%global grub_modules  " all_video boot blscfg btrfs             \\\
                        cat configfile cryptodisk               \\\
                        echo ext2 f2fs fat font                 \\\
                        gcry_rijndael gcry_rsa gcry_serpent     \\\
                        gcry_sha256 gcry_twofish gcry_whirlpool \\\
                        gfxmenu gfxterm gzio                    \\\
                        halt hfsplus http increment iso9660     \\\
                        jpeg loadenv loopback linux lvm luks    \\\
                        luks2                                   \\\
                        memdisk                                 \\\
                        mdraid09 mdraid1x minicmd net           \\\
                        normal part_apple part_msdos part_gpt   \\\
                        password_pbkdf2 pgp png reboot regexp   \\\
                        search search_fs_uuid search_fs_file    \\\
                        search_label serial sleep               \\\
                        squash4                                 \\\
                        syslinuxcfg                             \\\
                        test tftp version video xfs zstd "
```

*******************************************************************************
### If you are using systemd-boot on arm64 or riscv, is the fix for [unverified Devicetree Blob loading](https://github.com/systemd/systemd/security/advisories/GHSA-6m6p-rjcq-334c) included?
*******************************************************************************
we are not using systemd-boot.

*******************************************************************************
### What is the origin and full version number of your bootloader (GRUB2 or systemd-boot or other)?
*******************************************************************************
grub2-efi-x64-2.06-122.ev39.x86_64 (= Fedora grub2-efi-x64-2.06-118.fc39.x86_64 + Evren signature)

*******************************************************************************
### If your shim launches any other components apart from your bootloader, please provide further details on what is launched.
Hint: The most common case here will be a firmware updater like fwupd.
*******************************************************************************
shim only launches:

- our kernel
- memtest+86 v7
- fwupd-efi

*******************************************************************************
### If your GRUB2 or systemd-boot launches any other binaries that are not the Linux kernel in SecureBoot mode, please provide further details on what is launched and how it enforces Secureboot lockdown.
Skip this, if you're not using GRUB2 or systemd-boot.
*******************************************************************************

No other binaries.

*******************************************************************************
### How do the launched components prevent execution of unauthenticated code?
Summarize in one or two sentences, how your secure bootchain works on higher level.
*******************************************************************************
GRUB2 verifies signatures on booted kernels via shim, all the other expected
components are both verified by secureboot signatures and SBAT verification

*******************************************************************************
### Does your shim load any loaders that support loading unsigned kernels (e.g. certain GRUB2 configurations)?
*******************************************************************************
No
*******************************************************************************
### What kernel are you using? Which patches and configuration does it include to enforce Secure Boot?
*******************************************************************************
kernel-6.8.11-301.ev.fc39.x86_64 (= Fedora kernel-6.8.11-300.fc39.x86_64 + Evren signature)

*******************************************************************************
### What contributions have you made to help us review the applications of other applicants?
The reviewing process is meant to be a peer-review effort and the best way to have your application reviewed faster is to help with reviewing others. We are in most cases volunteers working on this venue in our free time, rather than being employed and paid to review the applications during our business hours. 

A reasonable timeframe of waiting for a review can reach 2-3 months. Helping us is the best way to shorten this period. The more help we get, the faster and the smoother things will go.

For newcomers, the applications labeled as [*easy to review*](https://github.com/rhboot/shim-review/issues?q=is%3Aopen+is%3Aissue+label%3A%22easy+to+review%22) are recommended to start the contribution process.
*******************************************************************************
We embrace totally that mentality and have contributed in the past to a few reviews:

- https://github.com/rhboot/shim-review/issues/387 (Mariner)
- https://github.com/rhboot/shim-review/issues/396 (LUX)
- https://github.com/rhboot/shim-review/issues/405 (Policorp Linux)
- https://github.com/rhboot/shim-review/issues/406 (Virtuozzo Linux)
- https://github.com/rhboot/shim-review/issues/408 (ZeronsoftN)
- https://github.com/rhboot/shim-review/issues/411 (Cisco)

We will of course continue to contribute as much as time permits.

*******************************************************************************
### Add any additional information you think we may need to validate this shim signing application.
*******************************************************************************
We essentially build on top of Fedora packages. When they release an update
on core system or boot packages, we compare, test, sign, and finally release the updates too.
