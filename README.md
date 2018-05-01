## Status

- [![Build Status](https://travis-ci.org/firepress-org/ghostfire.svg)](https://travis-ci.org/firepress-org/ghostfire)
- [![](https://images.microbadger.com/badges/image/devmtl/ghostfire.svg)](https://microbadger.com/images/devmtl/ghostfire "Get your own image badge on microbadger.com")
- [![](https://images.microbadger.com/badges/version/devmtl/ghostfire.svg)](https://microbadger.com/images/devmtl/ghostfire "Get your own version badge on microbadger.com")


## Why forking the offical Dockerfile ?

The elements I tweaked are:

- I want Ghost container to run under [tini](https://github.com/krallin/tini)
- Using node:8.11.1-alpine instead of Node:6
- Cleaner ENV management
- Uninstall during build `ghost cli` to safe few bytes in the docker image
- Use of `$SUB_VERSION` var for a better tagging of the docker image artifacts


## Run ghost with docker

**Option #1**:
- Run the script: `./runup.sh`

**Option #2**:

```
docker run -d \
—name ghostblog \
-p 2368:2368 \
-e url=http://localhost:2368 -e NODE_ENV=production \
devmtl/ghostfire:1.22.4D-9ebb479
```

Make sure to find the most recent docker image build. For the **statefull version**, see the section *Developper setup*.


## Finding what is the most recewnt docker image 🐳

- **Docker hub** — https://hub.docker.com/r/devmtl/ghostfire/tags/
- **Travis** — https://travis-ci.org/firepress-org/ghostfire

My builds produce many tags:

```
# THIS IS AN EXAMPLE
  
devmtl/ghostfire:1.22.4D-9ebb479
devmtl/ghostfire:1.22.4D
devmtl/ghostfire:edge
devmtl/ghostfire:9ebb4798cd6f18ae8b6eb90313ad00a002a9a8e9
devmtl/ghostfire:2018-04-30_03-13-05
```

I recommand to use the first format, where:
- `1.22.4` is the Ghost Version
- `D` is the sub version
- `9ebb479` is the git commit used to do the build

The logic is that I can test a **specific** image in UAT and push it in PROD as needed. In this example, using `devmtl/ghostfire:1.22.4D` could turn out to be a broekn docker image.  


## Developper setup

- Soon, I will share the setup I use on my Mac to develop Ghost Themes and test Ghost in general.


## Base image

- [node:8.11.1-alpine](https://registry.hub.docker.com/_/node/)


## Contributing

The power of communities, of pull request and forks, means that `1 + 1 = 3`. Help me make this repo a better one!

1. Fork it
2. Create your feature branch: `git checkout -b my-new-feature`
3. Commit your changes: `git commit -am 'Add some feature'`
4. Push to the branch: `git push origin my-new-feature`
5. Submit a pull request


## Copyright & License

Copyright (c) 2013-2017 Ghost Foundation - Released under the [MIT license](LICENSE).


## Sources & Fork

- **linear-build** This Git repo is available [here](https://github.com/firepress-org/ghostfire). It’s based on:
https://github.com/docker-library/ghost/tree/7eb6348d2a5493546577508d2cbae0a9922e1390/1/alpine

- **multi-build** — You might be interessed by a multi-build version. See https://github.com/mmornati/docker-ghostblog.


## Author

In the world of OSS (open source software) most people refer themselves as maintainers. The thing is I hate this expression. It feels heavy and not fun. I much prefer author.

Shared by [Pascal Andy](https://pascalandy.com/blog/now/). Find me on [Twitter](https://twitter.com/askpascalandy).