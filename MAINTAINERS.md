
## Publish updates

1. `./runversion.sh` / Ensure everything is fine
2. `./runtag.sh` / This will tag the commit and publish a release on Github

## ⚠️ Workflow warning

NEVER MERGE EDGE into MASTER!

- This would break the .travis instructions. It's because of the way our CICD is setup.
- Tag only from the master branch (the Ghost versions). Never tag from EDGE

## Why this funky setup? 

https://github.com/firepress-org/ghostfire#master-vs-edge
