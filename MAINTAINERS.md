# ⚠️ Workflow warning

1) Never merge EDGE into MASTER, this would break the .travis instructions

2) When the UAT is PASSED, MANUALLY replicate the Dockerfile from EDGE into MASTER. Again, we do this because don’t want to merge/squashed our .travis configurations.

3) Tag only from the master branch (the Ghost versions)

# CICD setup details

https://github.com/firepress-org/ghostfire#edge-vs-master
