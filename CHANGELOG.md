### About this changelog

Based on this [template](https://gist.github.com/pascalandy/af709db02d3fe132a3e6f1c11b934fe4). Release process at FirePress ([blog post](https://firepress.org/en/software-and-ghost-updates/)). Based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/) and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

### Status template

- ⚡️ Updates
- 🚀 New feat.
- 🐛 Fix bug
- 🛑 Removed
- 🔑 Security

# Releases

## 2.31.0
### ⚡️ Updates
- 2a88441 update .gitignore
- e57564b update LICENSE's format
- 07ad3a1 Update CHANGELOG format / squashed
- ea3230c Remove runlint.sh / its part of utility.sh
- 656a017 Remove renovate.json / no value
- 39ce10e Remove runrelease.sh / its part of utility.sh
- 98c8078 Remove runversion / its part of utility.sh
- 88d4b03 Add utility.sh
- ebe8588 Update variables
- 27121a0 Add license GNU v3

## 2.28.1
### ⚡️ Updates
- ff3e2ccb Ghost updated to 2.28.1 version
- bad034b6 Better copy
- c4292642 Update FUNDING.yml
- d6a72fff Create FUNDING.yml
- ea72a501 Better copy
- 0941efec Fix typo
- 445416ea changelog update

## 2.28.0
### ⚡️ Updates
- 4989a9e9 Ghost updated to 2.28.0 version

## 2.27.0
### ⚡️ Updates
- 59cc5396 Ghost updated to 2.27.0 version

## 2.26.0
### ⚡️ Updates
- 39eab43d update release process
- 3595a9a0 Ghost updated to 2.26.0 version
- 33f48fad update release process

## 2.25.9
- 7517e6e7 Ghost updated to 2.25.9 version
- 495c2196 Ghost updated to 2.25.9 version

## 2.25.8
### ⚡️ Updates
- cc5f5f6f Adding CHECKPOINT flag. Will make it easier to verify things in the logs
- 0162f7e7 Remove layer LAYER ghost-source as we don’t execute audit within the dockerfile
- 8f79f6ba Added screenshots
- 2500fe5b README wip
- 96916dce MAJOR updates
- 665db942 remove standalone scanner
- fa7c4471 re-introducing official docker test, better structure
- 467e312a bypass test / need to fix a glitch with sed
- b397d3c0 enable official docker tests / wip 1
- 958a989d Enable Trivy scanner, removing image pre-download, better testing suite
- b252d4f1 clean comments
- b18ad165 Ghost updated to 2.25.8 version

### ⚡️ Updates
- 618a27dd Ghost updated to 2.25.7 version

### ⚡️ Updates
- fb460617 update to 2.25.6

## 2.25.6
### 🛑 Removed
- ff75200e Travis / bypass test as America timezone fail the test
### ⚡️ Updates
- fdf013ed update to 2.25.6, added tzdata
- ccc57465 Ghost updated to 2.25.5 version
- 0eda3a7a Ghost updated to 2.25.4 version
- de88f909 Ghost updated to 2.25.3 version
- 299d4498 update to 2.25.1

## 2.25.1
### 🔑 Security
- 84e09557 Added caching layer, Scanners AquaSec + Trivy

### ⚡️ Updates
- 6175032b Ghost updated to 2.25.1 version
- 971d3545 Ghost updated to 2.25.0 version
- ae430dd9 minor update
- 04519493 minor updates
- 02f3efce Remove notes
- 67f1d823 Using multiple RUN to make logs clearer
- 45282ad0 Add layer ghost-what-to-upgrade
- 22a9e8be remove comment
- 7509ccf0 remove comment
- 940bf5d6 major feature updates since 2.24.4
- e8019107 minor comment
- 77c5e565 Better bash linting
- 2dd74ca9 minor commenting
- ee5c860d Add scan log
- 7df05b24 Added scan, local
- 8448b8c3 add scan - local
- ea9fcf64 Changelog 2.23.4

## 2.23.4

### ⚡️ Updates, MAJOR UPDATE part 1

- 02548676 Update Ghost to 2.23.4
- 164f5f77 comment updates
- e568d0ff simplify ghost-final layer
- 0a5dd642 remove layer ghost-to-scan
- fac4199b rename FROM
- 79b39842 Added layer ghost-source
- 9f74ae5e using RUN for this section
- 0b68f028 added npm config list
- f4129c1b new default ARG
- 84af7c14 Added WORKDIR, VOLUME, EXPOSE in the base layer
- e202cdcf using LABELS from opencontainer standard
- 73eccd44 now using node-core layer

### ⚡️ Updates, MAJOR UPDATE part 2
- 9b469594 Added / linting tool
- 6bce7558 Added layer to scan Aquasec / version for each apps
- eeebfeb4 MAJOR update / Creating node-core our of the official node image
- da339c97 MAJOR update / now using mhart/alpine-node:10.16
- 41a21ef8 Easier to read comments
- 149a915a RM ca-certificates in base image
- 30da41fb Add ca-certificates in base image

### Vulnerability Scanner for Containers

- https://gist.github.com/pascalandy/e313e094036f329482cc53ede6669c9c
- https://github.com/knqyf263/trivy

## 2.23.3
### 🚀 Added (new feat.)
- 23fcf508 MAJOR update, now with a base image

### 🐛 Fix bug
- eac49b54 added / git push

### ⚡️ Updates
- 1f4bfc48 what happened in 2.23.3
- 5c16f305 update to 10.16-alpine
- bf541c70 RM older Dockerfile pattern
- bb0d277d cleaner dummy var
- cfc16e90 RM older Dockerfile pattern
- e67f885f init
- 714f81f3 Init
- 9e5222bf adding folders to ignore
- 9fe4b3ff cleaner spacing + FIX VAR
- 404fdb9b minor / spacing fix
- 5e9f54df Ghost updated to 2.23.3 version
- 82975976 config / 6 hours by default
- 454150dc CHANGELOG updates
The scripts to update the tag + release on github was not clean. See MAINTAINERS.md
- 1909a30a splitting the process / part3
- 5875c73e splitting the process / part2
- bc3f388e splitting the process / part1
- 582a79f4 keep this script as standalone
- 9756ae13 rename files

## 2.23.2
### ⚡️ Updates
- 62c2727a RM tag comment
- 169c6783 Ghost updated to 2.23.2 version
- c61f6f0b cleaner labels / best practices /b
- 586581c2 cleaner labels / best practices
- ea9d3cc9 FIX with CLI 1.11.0
- 8909318b bump to Ghost 2.23.1 & CLI 1.10.1
	- 🛑 CLI 1.10.1 is buggy
- 5fa1a0d9 USER node must not be defined
- 4ed3d669 cleaner and optimized (2.22.3)
- 38c4b1ee RM chmod as it make the final image much bigger
- 009d1ca0 Added a chmod
- a616570e Added / COPY Dockerfile  and README
- c8de2c71 added file and dir
- 65c6aa7f comment out
- d47ce839 script update

## 2.22.3
### ⚡️ Updates
- 755dbcc0 Ghost updated to 2.22.3 version
- 138e660e Ghost updated to 2.22.3 version
- d54d6281 copyproofing

## 2.22.2
### 🐛 Fix bug
We had a nasty a bug. Our containers were running normally but under the hood there was a permission issue.

This happened at the same time we were testing our new multi-stage Dockerfile.
That complicated the debugging process.

It should be all good now.

- 9a3ef3cf 🐛 Fix bug / FIXED / permission issue is gone
- c83192b6 Fixed the permission issue we had

### ⚡️ Updates
- 407acbd7 Update renovate.json (#14)
- c89aee32 update to 2.22.2
- 5209aa4c rollback to single-stage
- 29bafeba added multi-stage
- 4c7fd945 renamed
- e9ac3e77 renamed
- 713fadb3 rollback accidental rename / runup.sh
- af522a61 🚀 Added (new feat.) / Added / renovate.json
- f1b50599 Ghost updated to 2.22.2 version
- 80e38553 added in the final build | su-exec
- 8b3f7935 a better README
- 21e32868 updated section / Why forking the official Docker image
- 02b75f58 changelog update
- 3f320520 🚀 Added (new feat.) / Rocking with multi-stage
- b21a931d Add Dockerfile-single-build
- 10937e01 update commit / version / update scripts

## 2.22.1
### ⚡️ Updates
- a06da861 Ghost updated to 2.22.1 version
- 45442dad maintainer / minor updates
- a10f0479 changelog minor updates
- c29af54f CHANGELOG update
- aa481c34 CHANGELOG update
- 7c8b9173 CHANGELOG update
### 🚀 Added (new feat.)
- 9b893dff rename run_version.sh
- 4abb004e rename version_is.sh
- fdf6f9ff Add update_push_version.sh in master

## 2.22.0
### 🚀 Added (new feat.)
- 3098c1c0 added config.production.json template file

### ⚡️ Updates
- ffd10d35 Bump to 2.22.0 / chown is recurisve / npm cache clean --force
- e7c3d9b6 README updates
- cd443593 README updates
- 0180bace copyproofing our README
- 45107504 changelog updates

## 2.21.1
### ⚡️ Updates
- 6e991c1e 2.21.1
- 57abf0b9 CLI update 1.10.0

## 2.21.0
### ⚡️ Updates
- 3ed5b456 update 2.21.0
- 01aad764 Now using ARG to simplify updates

## 2.20.1
### ⚡️ Updates
- 5a3c2bf1 2.20.1

## 2.19.4
### ⚡️ Updates
- 81871ce9 2.19.4

## 2.19.3
### ⚡️ Updates
- 7ef96a59 2.19.3

## 2.19.1
### ⚡️ Updates  
- e93347f6 changelog updates
- e0281b45 update to 2.19.1

## 2.18.3
### ⚡️ Updates  
- dd2efe74 update to 2.18.3
- 489f1b39 update to 2.18.2
- 5dae7eb7 update to 2.18.1

## 2.17.1
### ⚡️ Updates  
- 67412e3f update to 2.17.1

### 🐛 Fix bug
- Fixed a bug we openned: https://github.com/TryGhost/Ghost/issues/10578

## 2.16.4
### ⚡️ Updates  
- bcaaad37 update to 2.16.4
- 9956bb43 update to 2.16.3
- 95975955 Update to 2.16.2 AND manual sqlite3 installation

## 2.15.0
### ⚡️ Updates
- 0693f81e bump to 2.15.0
- 4b0b7b79 travis using branch only
- 9f60fc35 Manage secret locally
- b5e668e9 update gitignore
- ddf7f399 add push_release.sh
- b5b6836a Add a CHANGELOG.md to simplify releases

## 2.14.3
### ⚡️ Updates
- 0fa89cc4 update to 2.14.3
- f8cf2884 README update
- 4ba2eb39 README update
- 0664e8fe FIX README removed the wrong screenshot
- 59f34a1a README update
- 88464746 update to 2.14.3
- 5a4adc03 bump 2.14.2
- 0f7c9086 bump to 2.14.1

## 2.14.0
### ⚡️ Updates
- aa35cc36 bump to 2.14.0
- 07387d3c bump 2.14.0

## 2.13.2
### ⚡️ Updates
- cf33b4d8 update to Ghost 2.13.2 / node:10.15.1-alpine / better labels
- 19c35ffd better label
- 04237bb2 bump to node:10.15.1-alpine
- ebbbc3e1 update label
- 4e5b72ee fix typo in labels
- df73ccf5 bump to 2.13.2 typo fix
- 08abc80d bump to 2.13.2
- dfbf1293 add maintainer
- e5352867 bump to 2.13.1
- 77243a36 bump to 2.13.1
- 56889472 bump to 2.13.0
- 20643255 update before install
- f11df635 update before install

## 2.12.0
### ⚡️ Updates
- f24c1cfb bump to 2.12.0 / CLI 1.9.9 / node 10.15
- 794932ad bump to 2.12.0
- 3dda2cce bump to 2.11.1
- f990d416 bump to 2.11.0
- 9bd1ece8 bump to 2.10.2
- 08127bf4 bump cli 1.9.9
- d2a4b0e7 instruction updates
- b7bae42f instruction updates
- f2044ba3 minor README update
- 4ec4aea8 bump to 2.10.1
- 60ce6299 bump to 2.10.0 / node 10.5
- 6959ec30 cleaning flag in travis

## 2.9.1
### ⚡️ Updates
- 2f6496e0 bump to 2.9.1
- fd0e7917 README updates + cleaning flag in travis
- 4af246f3 bump to 2.9.1
- e96fbf1b readme update [ci skip]
- c545f372 fix IMAGE_VERSION flag which was in conflict in master img
- f44b15e4 fix formating tags
- 3460879f fix formating tags
- 302350ee better flag formatting / travis /b
- 605e00cc better flag formatting / travis
- 6671472c fix flag in travis
- a20e0284 bump to 2.9.0
- 52e3c698 Added MAINTAINERS.md

## 2.8.0
### ⚡️ Updates
- c5221ae6 bump to 2.8.0
- 7a0117e5 bump to 2.8.0
- a498a2f6 Fixing .travis.yml glitch /b
- 0e9ba4f7 Fixing .travis.yml glitch
- 4673e405 bump to 2.7.1
- fde44cca esthetic updates
- 6b74f525 major travis update /a
- e08473ee adding echo to better see tag in LOGS

## 2.7.0
### ⚡️ Updates
- 3e4e5132 bump to 2.7.0
- c28b6789 bump to 2.7.0
- 6ee2436e rollback from e7dbcbd8
- c134ada6 using node 10-alpine
- f3390ccd minor doc update
- 3bc6885f using node 8
- 292f36d6 bump 2.7.0 / still on CLI 1.9.8, node 10.14.1
- 0655a73b minor formatting
- 12b18d48 update / entrypoint
- e7dbcbd8 docker-entrypoint base on v2
- 11d810d7 back to single build /a
- 3f60b7f0 multistage build /i
- f99db610 multistage build /h
- 4364c7da multistage build /g
- 01d80024 multistage build /f
- 12e2b184 multistage build /e
- dd357908 multistage build /d
- 9cf97475 multistage build /c
- da01db63 multistage build /b
- 97ba507a multistage build /a
- e0f9dc13 minor comment update
- 2d77647c bump to node:10.14-alpine
- 56839f74 bump to node:10.14-alpine / removing the minor versionning
- c6f5e068 bump to node:10.14.1-alpine
- 5748e17f rename _EDGE_BRANCH.md
- a7a6613b remove healthcheck.js

## 2.6.2
### ⚡️ Updates
- 512f66b0 bump to ghost 2.6.2 / node:10.14.0
- 50fcd5c5 bump to node 10.14.0-alpine
- e3e9fa55 bump to 2.6.2
- 654f25ce rollback to 2.6.1 to test sheperd
- f79c53a1 rollback to 2.6.0 to test sheperd
- 15026c55 formatting only /b

## 2.6.1
### ⚡️ Updates
- 052d2d70 formatting only
- a86ae05a formatting only
- 9898a5b0 rollback curl
- 8677a847 Added healthcheck abord /1
- 8e8444dc Added healthcheck /3
- 275a9a2e Added healthcheck /2
- 3ccbca8b Added healthcheck / test is PASS
- f72c9c1b Added healthcheck
- b927ab0d Healthcheck.js test in progress

## older versions
### ⚡️ Updates
- be9079ef bump to 2.6.1
- c1ab643d bump to 2.6.1
- 0fbdd10b bump to 2.6.0
- 4cfc8853 bump to 2.6.0
- e0d00028 Bump to 2.5.0 / 1.9.8 / node 10.13.0
- 7d095e71 Bump to 2.5.0 / 1.9.8 / node 10.13.0
- 21d95378 Bump to 2.4.0 / 1.9.7 /  node:10.12.0-alpine
- cab87e6c bump to 2.3.0
- ff50fdca bump to 2.2.4
- c39452cd bump to 2.2.4
- 9618346b bump to 2.2.3
- 56347ca5 bump to 2.2.2 / 1.9.6 / node 8.12.0
- 0db941cb bump to 2.2.2
- 292cdb1f bump to 2.2.1
- 7d58d643 using official node:8.12.0-alpine
- 6beabdcb bump to 2.2.0 / 1.9.6
- 20baf469 using node 8.11.4
- 18c3e609 bump to 1.9.5 & node:8.12
- 5b663816 bump to 2.1.4
- fc1771ef roll back to / devmtl/node-alpine:8.11.4
- c98d4c8b moved back to official node:8.12.0
- c554c162 bump to 2.1.3
- cbfba661 bump to 2.1.2 and 1.9.4
- 2095b156 bump to 2.1.1
- a0a659b9 bump to CLI 1.9.3
- dcfffe64 removing flag --verbose
- 0d12300a using ghost install --verbose
- 63c4088b Bump to 2.1.0
- bd0a43d9 fix typo
- bfe675e1 bump to CLI 1.9.2
- 2a52fe8d rollback
- 048cb8e3 /b hack official node image to use alpine:3.8
- 9be208ac hack official node image to use alpine:3.8
- f1e0e4eb minor optimization
- 84e3b72c using my node build 8.11.4
- 22dde71f README update /10
- 1120d260 README update /8
- 98c11563 README update /7
- 6bf10cbb README update /7
- c6581fd0 update README /3
- 958e8227 update README /2
- b68eaf42 update README
- 6d851342 bump to 2.0.3 + 1.9.1
- fce3a71b rollback
- 072dad46 Trying to upgrade to alpine3.8
- 847c122b Still using 3.6
- 663b0360 update to alpine 3.8 / take 3
- 6150c10a update to alpine 3.8 / take 2
- 99e7742a update to alpine 3.8
- 0c0f94ae bump to 2.0.2
- f881229c Bump to Ghost 2.0.1 / CLI 1.9.0 / Node 8.11.4-alpine
- f1ab7d74 Bump to Ghost 2.0.0 / CLI 1.9.0 / Node 8.11.4-alpine
- bd41951b Bump to Ghost 2.0.1 / CLI 1.9.0 / Node 8.11.4-alpine
- 9e38cf22 Bump t0 .25.5 and CLI 1.9.0
- 36fc39cc on 1.25.5 /w CLI 1.9.0
- ecc2ce32 bump to 1.25.5
- aeff42dc bump to 1.25.4
- 6d213497 bump to 1.25.4
- 9ee6f654 bump to 1.25.3
- 9ce513b3 bump to 1.25.2
- 2febe2bd bump to 1.24.9
- 6c1b3348 Minor updates
- 7c666261 FIX few typos
- 30551d5b MJR README update
- be27c773 add sponsor
- 3de4a0f4 following master
- a0d0e7a6 minor optimisations
- b027ffc0 READme update
- 6fe4ac3c readme update
- 583cc3fe update with more possible issues (#11)
- 79fa76a2 add comments
- de4a7201 new ARCH for arm,arm64,amd64 (#10)
- a12f3c0f bump to Ghost 1.24.8 / CLI 1.8.1 / node 8.11.3 (#9)
- 2c668090 bump to 1.24.8
- 54f25275 bump to 1.24.7
- b1f63f08 BUMP to 1.24.6
- eb21c584 bump to 1.24.5
- ec69bf16 bump to 1.24.4 and node 8.11.3
- cf1e8fd8 ghost 1.24.3
- 4208772d Add .gitignore
- c8cacdf6 ghost 1.24.1 and CLI 1.81.
- 1507448b bypass healthcheck
- 7521580c rolling back to 1.22.8 and 1.7.3
- 554f0e54 trying healthcheck
- fc80b6ff bypass healthcheck
- 72152250 BUMP to 1.24.1
- c8dc17d8 due diligence
- b5b62124 Added healtcheck
- 5d3ef9c5 Add new ARCH options
- 468db1bc bump to 1.24.0 and CLI 1.8.1
- 10baa33d fix: minor, fix tag printf (#8)
- 1a62974e Adding a space / code reading optimisation (#7)
- 98e4d1a9 Adding tag IMAGE_FULL (#6)
- 4cd5948e Update DATE format for image tag
- 108a0d62 Add curl + ca-certificates (#5)
- b49e4482 RM older comment
- f5cd0003 Added a space to better read the code
- a7497360 rollback to 1.23.1 to test Buddy CICD /D
- 37398292 rollback to 1.23.0 to test Buddy CICD /C
- 21fa2d72 rollback to 1.23.1 to test Buddy CICD /B
- ff02804e roll back to 1.23.0 to test buddy CICD /A
- 5d810648 bump to node:8.11.2-alpine (#4)
- 064789ae bump CLI to 1.8.0 (#3)
- 1663cc49 use curl (npm 404 issue at the moment)
- d596f9a6 Add travisbuddy + replaced curl with wget
- 43f6a5f4 READme update to trigger buddy
- 0e752ea5 update to node:8.11.2-alpine
- 1c98dddd update to 1.23.1 and CLI 1.8.0
- aa1805a4 using curl instead of wget
- eb0f6962 add ca-certificat
- 6758dad6 add wget
- 609b28b0 bump to 1.23.0
- ee59c773 bump to 1.22.8
- 0252f8ef Merge pull request #2 from firepress-org/add-stickler-config
- 7add9556 Adding .stickler.yml
- c1e723bf bump to 1.22.8
- df7f8bc8 Remove ignored files
- 94927f0f add .gitignore
- ff011cfd bump to ghost 1.22.7 and CLI 1.7.3
- 9c81f39e bump to 1.22.7 and 1.7.3
- 621fd9b8 READme update
- f45eca31 READme update
- ea389bd5 READme update
- 75c1ed41 READme update
- 2c6bf351 Travis minor update
- 7112645e READme update
- f83f87c8 READme update
- b61f9c87 READme update
- 9f2c70ea following Dockerfile from master branch
- c0919d8a remove sub version var
- 7d62ebaa bump ghost CLI 1.7.2
- 99362ec2 READme update
- 67b26037 READme update
- 411c8504 READme update
- 92469f16 add screenshot
- f7b49321 removed some echo commands
- 5187a5a5 READme update
- 112f2a22 update tag under the branch edge
- f5f09523 push to 1.22.5
- 58fbd802 minor
- 42418657 bump to 1.22.5
- a6c78b1d Dockerfile / fix CHAR
- 7434aa13 Travis debug build /A
- 513d0707 roll back to 1.22.4
- e2feb26d push to 1.22.5
- ec3bd02f Travis / Add edge tag from follow-release
- bdb1e5de Travis / Removed edge tag from master
- c58cb8b8 Travis / Removed else simplied tags /D
- 5d8db434 Travis / fixed glitch simplied tags /C
- 69e8e945 Travis / simplied tags /b
- fcb7bef3 Travis / simplied tags /a
- 9c9cb066 rm few branch that bypass CI
- 40f4e882 rm few branch that bypass CI
- 51d3118c fix comment
- bbab65fe fix comment
- a90599dc fix branch / was not master
- cdb63d5c fix docker push
- ee1bab82 new branch follow-release
- cf94b80e update image ci skip
- c872c937 Many many updates / Too many things all together I know ...
- 157a2c17 Travis / tag management GHOST_VERSION / E
- 59003a03 Travis / Better management of GHOST_VERSION / D
- 6873086b Travis / Better management of GHOST_VERSION
- 1af078e0 Travis / GHOST_VERSION_FROM_DOCKERFILE /A
- 6385365e readme update /b
- 90b77ae4 readme update
- 903ff8c1 readme update
- 9ebb4798 Travis / clean up
- 29e168dc Travis / putting build and push after_success /A
- 1cb8c532 Travis / fix a VAR /G
- fb2e7abe Travis / New tag EDGE /F
- 81b4f1d2 Travis / New tag EDGE /E
- 78e64c13 Travis / Better tagging and better unit tests /C
- 6d976cf0 Travis / Better tagging and better unit tests /B
- 553ee8a9 Travis / Better tagging and better unit tests /A
- a6962189 Travis / fix tag and push /B
- 039b4c98 Travis / fix tag and push A
- 4b0c3bb7 Travis, adding TAGS /D
- de1a897b Travis, adding TAGS /D
- 81152271 Travis, adding TAGS /C
- 9b46c02c Travis, adding TAGS /B
- ae26d0a1 Travis, adding TAGS
- ba17a2eb readme, fixing badges
- 142535be readme update /D + Travis updates, test were failing
- fb608c08 readme update /C
- ea182fbe readme update /b
- 43cfb511 readme update
- 46405567 ghostfire Travais /J
- f10d16ff ghostfire Dockerfile rm timezone that cause issue with Travais
- ee949d2b ghostfire Travis config /H
- f63a606d ghostfire Travis config /G
- 58287ba4 init Travis config /F
- 11742862 init Travis config /R
- 2c3e5e38 init Travis config /D
- 92f4b104 init Travis config /C
- d89629c3 init Travis config /B
- 4c6c95a9 init Travis config /A
- e607d9ac major refactoring as I only use Alpine my base
- 7eb6348d Update to 1.22.4, ghost-cli 1.7.1
- c249c383 Update generated README
- 2f6ac6c7 Update to 1.22.3, ghost-cli 1.7.1
- 8e29a02e Update to 1.22.2, ghost-cli 1.7.1
- 77ace608 Update to 1.22.1, ghost-cli 1.7.1
- 149dd4f4 Update to 1.22.1, ghost-cli 1.7.0
- 47f1ab87 Update to 1.22.1, ghost-cli 1.6.0
- f1e7025f Update to 1.22.0, ghost-cli 1.6.0
- c79228d3 Update to 1.21.7, ghost-cli 1.6.0
- 6554779f Update to 1.21.7, ghost-cli 1.5.2
- e803c66c Update to 1.21.6, ghost-cli 1.5.2
- 61cbf8b5 Update to 1.21.5, ghost-cli 1.5.2
- 96deac79 Update to 1.21.4, ghost-cli 1.5.2
- b58ead46 Update to 1.21.3, ghost-cli 1.5.2
- b4d64e31 Update to 1.21.2, ghost-cli 1.5.2
- 6a3fa7ee Update to 1.21.1, ghost-cli 1.5.2
- 962323a5 Update to 1.21.1, ghost-cli 1.5.1
- 572460ad Update to 1.20.3, ghost-cli 1.4.2
- 89601afa Update to 1.20.2, ghost-cli 1.4.2
- bb037471 Update to 1.20.1, ghost-cli 1.4.2
- df02b553 Update to 1.20.0, ghost-cli 1.4.2
- 832c9278 Update to 1.19.2, ghost-cli 1.4.2
- 719b2902 Update to 1.19.2, ghost-cli 1.4.1
- c802ef9a Update to 1.19.1, ghost-cli 1.4.1
- 1e506751 Update to 1.19.0, ghost-cli 1.4.1
- 88e372c0 Update to 1.18.4, ghost-cli 1.4.1
- 6b68444d Update to 1.18.4, ghost-cli 1.4.0
- 1e75029f Update to 1.18.3, ghost-cli 1.4.0
- cc2f464d Update to 1.18.2, ghost-cli 1.4.0
- 979e837a Update to 1.18.2, ghost-cli 1.3.0
- 88fd2c82 Update to 1.18.1, ghost-cli 1.3.0
- ab26d8e4 Update to 1.18.0, ghost-cli 1.3.0
- 8ddece4d Update to 1.17.3, ghost-cli 1.3.0
- d0f88d93 Update to 1.17.3, ghost-cli 1.2.1
- f7fe8c84 Merge pull request #105 from infosiftr/knex-path
- 6f86e799 Update to 1.17.2, ghost-cli 1.2.1
- 93388414 Update to 1.17.1, ghost-cli 1.2.1
- aabeb833 Update to 1.17.1, ghost-cli 1.2.0
- 56a3e1f6 Adjust knex-migrator to be in the PATH directly instead of symlinking
- f434a4b0 Update to 1.17.0, ghost-cli 1.2.0
- c624395a Merge pull request #101 from infosiftr/sqlite3
- a5c9dd0d Fix sqlite3 for non-amd64 arches
- 777cb093 Update to 1.16.2, ghost-cli 1.2.0
- f73d0a97 Update to 1.16.1, ghost-cli 1.2.0
- fbe680f2 Merge pull request #100 from infosiftr/NODE_ENV=development
- 938b1a2d Update to 1.16.0, ghost-cli 1.2.0
- c4d49c0e Update to 1.16.0, ghost-cli 1.1.3
- 1761097e Add a config symlink for NODE_ENV=development
- 36484438 Update to 1.15.1, ghost-cli 1.1.3
- 75b0977d Update to 1.15.0, ghost-cli 1.1.3
- 7c8b79ec Update to 1.14.1, ghost-cli 1.1.3
- 6081c3a2 Update to 1.14.0, ghost-cli 1.1.3
- 44dc27d0 Update to 0.11.12
- 6ebc6712 Update to 1.13.0, ghost-cli 1.1.3
- 1f0facfc Update to 1.12.1, ghost-cli 1.1.3
- cc73035b Update to 1.12.1, ghost-cli 1.1.2
- 2ef499bc Update to 1.12.0, ghost-cli 1.1.1
- 5325106d Update to 1.11.1, ghost-cli 1.1.1
- d0734304 Update to 1.11.0, ghost-cli 1.1.1
- 1c8478b4 Update to 1.10.0, ghost-cli 1.1.1
- eabf5910 Update to 1.9.1, ghost-cli 1.1.1
- 1249536b Update to 1.9.0, ghost-cli 1.1.1
- 4b5a3383 Update to 1.8.7, ghost-cli 1.1.1
- 8a63e148 Update to 1.8.6, ghost-cli 1.1.1
- 815762e5 Update to 1.8.5, ghost-cli 1.1.1
- e4c22ee5 Update to 1.8.4, ghost-cli 1.1.1
- c5c8e3ce Update to 1.8.3, ghost-cli 1.1.1
- 901ac387 Update to 1.8.2, ghost-cli 1.1.1
- 0dbad8d9 Update to 1.8.1, ghost-cli 1.1.1
- 2e32ab6f Update to 1.8.0, ghost-cli 1.1.1
- d9be554e Merge pull request #85 from infosiftr/ugh
- 0a3f9385 Add "g++" and "libc6-dev" to installation of Ghost 0.x buildDeps for non-precompiled platforms to build sqlite3
- 81e8d8cb Update to gosu 1.10
- 5d726104 Merge pull request #82 from infosiftr/multiarch
- 8d1ed041 Add proper Architectures entries in "generate-stackbrew-library.sh"
- 66a99190 Update to 1.7.1, ghost-cli 1.1.1
- 2f5e955e Update to 1.7.0, ghost-cli 1.1.1
- 914dd83f Update to 1.6.2, ghost-cli 1.1.1
- 3989f7fc Update to 1.6.1, ghost-cli 1.1.0
- ecec7a30 Update to 1.6.0, ghost-cli 1.1.0
- 1b107f7b Update to 1.5.2, ghost-cli 1.1.0
- a9b023e9 Update to 1.5.2, ghost-cli 1.0.3
- 32665816 Update to 1.5.1, ghost-cli 1.0.3
- 2df6e2c3 Merge pull request #72 from infosiftr/old-drop
- fabb2475 Remove unsupported versions, https://dev.ghost.org/ghost-1-0-0/
- aa4d789b Merge pull request #68 from infosiftr/more-versions
- 4c1b1268 Add version 1.5 (and update latest)
- 15d03808 Add 1.4 too
- 34ab977f Automate ghost-cli bumps too
- 9aeff503 Add new releases of ghost from this past week
- 1f9de663 Merge pull request #67 from acburdine/1.0
- d0377bfe Debian uses gosu, not su-exec
- 3b687c49 Catch case when users mount an empty or partial content directory
- 09ff7191 add docker configurations for 1.0
- b8f9e827 update base node version to 6 for 0.11.x versions
- 08813e7f Update to 0.11.11
- 9bc8fab0 Update to 0.11.10
- 2497f866 Add support in "update.sh" for "X.Y-rc" folders
- 91fcdc47 Merge pull request #66 from infosiftr/multiversion
- ee2ce866 Update repository structure for multi-version support
- 8435a221 Update to 0.11.9
- 1e9307eb Update to 0.11.8
- b174b0b1 Merge pull request #55 from infosiftr/alpine
- 7251ebfe Add initial alpine variant
- f57b040e Update to 0.11.7
- c36d9e20 Add "travis_retry" to our build to reduce transitory failures
- 12006b77 Update to 0.11.5
- 2abbd2be Update to 0.11.4
- 46432abb Merge pull request #54 from infosiftr/any-user
- 3aae08ae Allow arbitrary --user values
- 4128e2c4 Added support for custom UID/GID by using enviroment variables PUID/PGID
- 4afb4dbe Update Ghost download URL
- 9e952283 Update to 0.11.3
- 66c839be Update to 0.11.2
- 8d638ab5 Update to 0.11.1
- ebe493d6 Update README with Jenkins badge change (see https://github.com/docker-library/docs/pull/697)
- bd1a0070 Ignore alphas just like betas
- e9592030 Update to 0.11.0
- fb75afe5 Merge pull request #44 from pascalandy/master
- 89dfe2bc https://dev.ghost.org/ghost-0-10-1/
- 76c1d792 Merge pull request #43 from chorrell/jessie-curl
- 3718f256 Don't install ca-certificates or wget
- b1a49c5d Update to 0.10.0
- 6af21e67 Merge pull request #39 from sasvdw/master
- 13c06085 Bumped version used in Dockerfile
- e625fca1 Update from Node 4.2 to just Node 4 (following Node LTS)
- 8652c806 Convert "generate-stackbrew-library.sh" to output the new 2822-based format
- 0663fa9f Ignore "beta" releases (for now?)
- dd8e79cf Update to 0.8.0
- 0cb6f862 Fix embarassing README.md typo (https://github.com/docker-library/docs/pull/557)
- dce058cc Update to 0.7.9
- 8c0d010d Merge pull request #31 from infosiftr/copy-themes-explicitly
- 8a14dc96 Merge pull request #30 from infosiftr/fix-gpg
- 90bbbe4a Explicitly copy all themes separately to ensure the "casper" theme is always available
- fb7a0de4 Fix "gpg" usage to stop relying on deprecated and insecure behavior
- bb7274f3 Update to 0.7.8
- 1e4098ce Update to 0.7.6
- 6b6ffbf7 Run update.sh
- 16a6fd35 Update to 0.7.4
- fd8e24cd Update ghost to 0.7.3
- 0cbbf7d6 Merge pull request #24 from lwis/master
- 0e550c21 Update to node 4.2, gosu 1.7, and Ghost 0.7.2
- a18792ad Update .travis.yml to account for Travis changes (especially now that Docker is no longer experimental :tada:)
- 3f60a24d Update README.md stub
- 90106aa0 Add Travis CI badge
- 19945331 Switch update.sh to use "git ls-remote" instead of hitting the GitHub API
- 7894865d Merge pull request #21 from vegasbrianc/master
- aa37feba Update to 0.7.1
- 5e10181c Updated version to 0.7.1
- 6eb29f45 Update to 0.7.0
- 7200faa1 Enhance "generate-stackbrew-library.sh" to only take into account changes to the Dockerfile or files from COPY in the Dockerfile for choosing the commit hash for a particular directory
- 4384e4e5 Put "docker images" in .travis.yml "after_script" section
- 796b4ff4 Add initial .travis.yml
- 853fca51 Add "-f" to curl invocations
- acecb713 Run update.sh, bump 0.6.4
- a68d52ed Update to 0.6.3
- 44ea66fd Merge pull request #11 from kdelfour/master
- 79fd9cb7 Update Dockerfile to 0.6.2
- 55da233b Merge pull request #10 from Swatto/master
- 7afddd95 Update Ghost version to 0.6.0
- c63006a7 Merge pull request #8 from infosiftr/more-defensive-copy
- 2fb73b3a Update "content" copy to be more defensive of exact subdirectory names
- 6fe66a29 Merge pull request #6 from soupdiver/separate_init_checks
- e97e92b7 check directories one by one and not depend only on config.js
- d07b3e67 Use && instead of ; for consistency
- 6175e16d Merge pull request #4 from md5/cleaner-image
- a9085966 Clean up artifacts from installing ghost
- 2b93aa26 Update to 0.5.10
- 4ee388e3 Update to 0.5.9
- 33d2ce4d 2015
- f54e5465 Merge pull request #1 from infosiftr/non-root
- 6c9ed953 Run as non-root by default
- 3c21e629 Add update.sh
- 181dd2ea Add generate-stackbrew-library.sh
- c4de4e27 Add Dockerfile
- 3c438529 Add initial README stub
- 294e95eb Add initial LICENSE

