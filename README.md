## Status

- [![Build Status](https://travis-ci.org/firepress-org/ghostfire.svg)](https://travis-ci.org/firepress-org/ghostfire)
- [![](https://images.microbadger.com/badges/image/devmtl/ghostfire.svg)](https://microbadger.com/images/devmtl/ghostfire "Get your own image badge on microbadger.com")
- [![](https://images.microbadger.com/badges/version/devmtl/ghostfire.svg)](https://microbadger.com/images/devmtl/ghostfire "Get your own version badge on microbadger.com")


## About Ghost our favorite CMS

Ghost is a free and open source website & blogging platform designed to simplify the process of online publishing for individual bloggers as well as online publications. It’s a CMS (content management system) designed to be better alternative to  WordPress, Drupal, Medium, Tumblr, etc.


## How to use this image

**Option #1**:
- Locally, run the script: `./runup.sh`

**Option #2**:

```
docker run -d \
—name ghostblog \
-p 2368:2368 \
-e url=http://localhost:2368 -e NODE_ENV=production \
devmtl/ghostfire:1.22.5-f5f0952
```

**Stateful**

```
docker run -d \
—name ghostblog \
-p 2368:2368 \
-e url=http://localhost:2368 -e NODE_ENV=production \
-v /path/to/ghost/blog:/var/lib/ghost/content \
devmtl/ghostfire:1.22.5-f5f0952
```

**Breaking change**

If you want to run Ghost 0.11.xx, be aware of the container's path difference:

Ghost 1.x.x is: /var/lib/ghost/content
Ghost 0.11.x is: /var/lib/ghost

**SQLite Database**

This Docker image for Ghost uses SQLite. There is nothing special to configure.

**What is the Node.js version?**

```
docker exec <container-id> node --version
```


## Find the most recent docker image 🐳

- **Docker hub** — https://hub.docker.com/r/devmtl/ghostfire/tags/
- **Travis** — https://travis-ci.org/firepress-org/ghostfire

My docker images are tagged as follow:

```
# master branch tags examples:
  
devmtl/ghostfire:1.22.5-f5f0952
devmtl/ghostfire:1.22.5
devmtl/ghostfire:20180504_20H18_37

# edge branch tags examples:

devmtl/ghostfire:1.22.5-edge-112f2a2
devmtl/ghostfire:edge

```

I recommand to use the first tag, where:
- `1.22.5-f5f0952` means the **Ghost Version** + the **SHA of the git commit** used to create the build.
- The logic is that I can use a **specific** test it and push it in PROD as needed. In this example, using `devmtl/ghostfire:1.22.5` could turn out to be a broken docker image.  
- **DO NOT** use the **multistage** tags at this point. It is not stable.

## Developper setup

- Soon, I will share the setup I use on my Mac to develop Ghost Themes and test Ghost in general.


## Why forking the offical Dockerfile ?

The elements I tweaked are:

- Ghost container is running under [tini](https://github.com/krallin/tini)
- Using `node:8.11.1-alpine` instead of Node:6
- Cleaner ENV management
- Uninstall the `ghost cli` to safe some sapce in the docker image
- Eventually, I will use multi-stage builds


## Branches: edge vs master

Because I run a lot of websites in production using this image, I prefer to do my tests using a dedicated `edge` branch.

Once I confirm the edge build PASS, I update the Dockerfile under the `master` branch as well. At this point, I’m really confident the docker image is working perfectly.

![branch-explanation](https://user-images.githubusercontent.com/6694151/39652598-20980092-4fbc-11e8-9471-84f1cbcb1f4b.jpg)


## Contributing

The power of communities, pull request and forks means that `1 + 1 = 3`. Help me make this repo a better one!

1. Fork it
2. Create your feature branch: `git checkout -b my-new-feature`
3. Commit your changes: `git commit -am 'Add some feature'`
4. Push to the branch: `git push origin my-new-feature`
5. Submit a pull request


## Copyright & License

View **MIT** license information at https://ghost.org/license/ for the software contained in this image.

As with all Docker images, these likely also contain other software which may be under other licenses (such as Bash, etc from the base distribution, along with any direct or indirect dependencies of the primary software being contained).

Some additional license information which was able to be auto-detected might be found in the repo-info repository's ghost/ directory.

As for any pre-built image usage, it is the image user's responsibility to ensure that any use of this image complies with any relevant licenses for all software contained within.


## Sources & Fork

- **linear-build** This Git repo is available [here](https://github.com/firepress-org/ghostfire). It’s based on:
https://github.com/docker-library/ghost/tree/7eb6348d2a5493546577508d2cbae0a9922e1390/1/alpine

- **multi-build** — You might be interessed by a multi-build version. See https://github.com/mmornati/docker-ghostblog.


## Author

In the world of OSS (open source software) most people refer themselves as maintainers. The thing is… I hate this expression. It feels heavy and not fun. I much prefer author.

Shared by [Pascal Andy](https://pascalandy.com/blog/now/). Find me on [Twitter](https://twitter.com/askpascalandy).