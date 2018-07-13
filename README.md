## Status

- [![Build Status](https://travis-ci.org/firepress-org/ghostfire.svg)](https://travis-ci.org/firepress-org/ghostfire)
- [![](https://images.microbadger.com/badges/image/devmtl/ghostfire.svg)](https://microbadger.com/images/devmtl/ghostfire "Get your own image badge on microbadger.com")
- [![](https://images.microbadger.com/badges/version/devmtl/ghostfire.svg)](https://microbadger.com/images/devmtl/ghostfire "Get your own version badge on microbadger.com")


## About Ghost our favorite CMS

[Ghost](https://ghost.org/) is a free and open source website & blogging platform designed to simplify the process of publishing. It’s individual bloggers as well as online publications. You can see Ghost as a CMS (content management system) designed to be better alternative to systems like: *WordPress, Drupal, Medium, Tumblr*, etc.


## How to use this image

**Option #1**:
- Locally, run the script: `./runup.sh`

**Option #2**:

```
GHOSTFIRE_IMG="devmtl/ghostfire:edge"

docker run -d \
—name ghostblog \
-p 2368:2368 \
-e url=http://localhost:2368 -e NODE_ENV=production \
"$GHOSTFIRE_IMG"
```

**Option #3 (Stateful)**

```
GHOSTFIRE_IMG="devmtl/ghostfire:edge"

docker run -d \
—name ghostblog \
-p 2368:2368 \
-e url=http://localhost:2368 -e NODE_ENV=production \
-v /myuser/local-dev-path/ghost/content:/var/lib/ghost/content \
"$GHOSTFIRE_IMG"
```

### Find the most recent docker image 🐳

Instead of using edge (*most people use latest but I prefer edge :-p*) use the **stable image**.

- **Docker hub** — https://hub.docker.com/r/devmtl/ghostfire/tags/
- **Travis** — https://travis-ci.org/firepress-org/ghostfire

I recommand to use the **stable tag**, where:
- `1.24.8-583cc3f-20180713_01H3604` is the **Ghost Version** PLUS the **SHA of the git commit** PLUS the date when the image was create.
- The logic is that I can use a **specific** image to test and push it in PROD as needed. In this example, using `devmtl/ghostfire:1.22.5` could turn out to be a broken docker image and is not best practice. 

As an example:

### edge branch tags are:

```
devmtl/ghostfire:1.24.8-edge-79fa76a
devmtl/ghostfire:edge
```

### master branch (stable) tags are:

```
devmtl/ghostfire:1.24.8-583cc3f-20180713_01H3604
devmtl/ghostfire:1.24.8-583cc3f
devmtl/ghostfire:1.22.8
devmtl/ghostfire:20180713_01H3604
```

### Branches: edge vs master

Because I run a lot of websites in production using this image, I prefer to do my tests using a dedicated `edge` branch.

Once I confirm the edge build PASS, I update the Dockerfile under the `master` branch as well. At this point, I’m really confident the docker image is working perfectly.

![ghostfire-screen-2018-07-12_21h46](https://user-images.githubusercontent.com/6694151/42668147-195cfb74-861d-11e8-9d61-d847da6147f9.jpg)


## Various info

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

You can also see this information in the Dockerfile and in the Travis builds.


## Developper setup

[I open sourced](https://github.com/firepress-org/ghost-local-dev-in-docker) the local setup. This is a workflow to run Ghost locally within a docker container. It allows you to easily develop Ghost themes and/or Ghost itself.


## Why forking the offical Dockerfile ?

I tweaked elements like:

- Ghost container is running under [tini](https://github.com/krallin/tini)
- Using `node:8.11.3-alpine` instead of Node:6
- Better ENV var management
- Uninstall the `ghost cli` to safe few bytes in the docker image


## Contributing

The power of communities, pull request and forks means that `1 + 1 = 3`. Help me make this repo a better one!

1. Fork it
2. Create your feature branch: `git checkout -b my-new-feature`
3. Commit your changes: `git commit -am 'Add some feature'`
4. Push to the branch: `git push origin my-new-feature`
5. Submit a pull request


## Mobile devices and browsers testing

Driven by: [BrowserStack](https://www.browserstack.com/automate)

![screen shot 2018-07-13 at 7 53 03 am](https://user-images.githubusercontent.com/6694151/42690356-e362ad7a-8671-11e8-9e90-fb49d7e2a807.jpg)

## Copyright & License

View **MIT** license information at https://ghost.org/license/ for the software.

The fork is released under the **GNU** [license](https://github.com/pascalandy/GNU-GENERAL-PUBLIC-LICENSE).

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