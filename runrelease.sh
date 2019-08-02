# Requires that we already and a branch tagged.
# Usually via Tower

# This is specific to my local set up
source .env .

# vars
#GITHUB_TOKEN="3122133122133211233211233211233211322313123"
#local_repo="$Users/.../docker-stack-this"
user="firepress-org"
git_repo="ghostfire"


# The tag must be ready to push on git remote
#
cd ${local_repo} && \
git push --tags && \

# Find the latest tag
#
tag_version="$(
	git ls-remote --tags https://github.com/${user}/${git_repo} \
		| cut -d$'\t' -f2 \
		| cut -d/ -f3 \
		| tail -n1)" && \

# confirm
echo ${tag_version} && \

# Requires https://github.com/aktau/github-release
$GOPATH/bin/github-release release \
  --user ${user} \
  --repo ${git_repo} \
  --tag ${tag_version} \
  --name ${tag_version} \
  --description "Refer to [CHANGELOG.md](https://github.com/firepress-org/ghostfire/blob/master/CHANGELOG.md) for details about this release."
