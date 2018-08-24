## Continuous integration (CI) status

- [![Build Status](https://travis-ci.org/firepress-org/ghostfire.svg)](https://travis-ci.org/firepress-org/ghostfire)
- [![](https://images.microbadger.com/badges/image/devmtl/ghostfire.svg)](https://microbadger.com/images/devmtl/ghostfire "Get your own image badge on microbadger.com")
- [![](https://images.microbadger.com/badges/version/devmtl/ghostfire.svg)](https://microbadger.com/images/devmtl/ghostfire "Get your own version badge on microbadger.com")

## What is this

It’s a Docker image for running Ghost in a container.


## About Ghost our favorite CMS

[Ghost](https://ghost.org/) is a free and open source website & blogging platform designed to simplify the process of publishing. It’s for individual bloggers as well as online publications. You can see Ghost as a CMS (content management system) designed as an alternative to systems like *Medium, WordPress, Squarespace, Wix, Tumblr, Drupal, Zoola*, etc.

On the other side, the idea behind **FirePress** is to empower freelancers and small organizations to be able to build an outstanding mobile-first website. **We exclusively host Ghost websites**.

Because we believe your website should speak up in your name, we consider our mission completed once your site has become [your impresario](https://play-with-ghost.com/ghost-themes/why-launching-your-next-website-with-firepress/).


##  Live Demo

Head over to the [Live Demo](https://play-with-ghost.com/ghost-themes/playground/) section, and see what Ghost can do for you. Thanks to `play-with-ghost.com` you can even login directly into the **admin panel** by using the available credentials. You can also see and try many Ghost **Themes**.

We you can try **Ghost version 2** here:<br>
https://play-with-ghost.com/ghost-themes/firepress-vapor-for-barbershops/


## How to use this image

To run Ghost in a Docker container, here is the setup I use in production. Just execute `runup.sh` bash script and you are good to go. This setup also allows you to run your blog under a subdirectory like `mysite.com/blog`.

Ensure you have Docker installed on your server. To update your Ghost container, just stop the container and execute to runup.sh again.

**Option #1**:
- Run the script: `./runup.sh`

**Option #2**:

```
GHOSTFIRE_IMG="devmtl/ghostfire:1.24.8-583cc3f"

docker run -d \
—name ghostblog \
-p 2368:2368 \
-e url=http://localhost:2368 -e NODE_ENV=production \
"$GHOSTFIRE_IMG"
```

**Option #3 (Stateful)**

Don’t forget to change the path on your local drive!

```
GHOSTFIRE_IMG="devmtl/ghostfire:1.24.8-583cc3f"

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

As an example:

### master branch (stable) tags looks like:

```
devmtl/ghostfire:1.24.8-583cc3f-20180713_01H3604
devmtl/ghostfire:1.24.8-583cc3f
devmtl/ghostfire:1.22.8
devmtl/ghostfire:20180713_01H3604
```

I recommend to use the **stable tag**, where:
- `1.24.8-583cc3f-20180713_01H3604` is the Ghost **version** + the **SHA** of the git commit + the **date**.
- The logic is that I can use a **specific** image to test and push it in PROD as needed. In this example, only using `devmtl/ghostfire:1.24.8` could turn out to be a broken docker image and is not the best practice. 


### edge branch tags looks like:

```
devmtl/ghostfire:1.24.8-edge-79fa76a
devmtl/ghostfire:edge
```


### Branches: edge vs. master

Because I run a lot of websites in production using this image, I prefer to do my tests using a dedicated `edge` branch.

Once I confirm the edge build PASS, I update the Dockerfile under the `master` branch as well. At this point, I’m reaaaaaally confident the docker image is working correctly.

![ghostfire-screen-2018-07-12_21h46](https://user-images.githubusercontent.com/6694151/42668147-195cfb74-861d-11e8-9d61-d847da6147f9.jpg)


## Developer setup

[I open sourced here](https://github.com/firepress-org/ghost-local-dev-in-docker). It’s a workflow to run Ghost locally within a Docker container. Once your local paths are define it’s really fun and easy to work between many themes.


## Various

**Breaking change**


- Ghost 2.x.x is: /var/lib/ghost/content
- Ghost 1.x.x is: /var/lib/ghost/content
- Ghost 0.11.x is: /var/lib/ghost

*If you still run Ghost 0.11.xx, be aware of the container's path difference.*

**SQLite Database**

This Docker image for Ghost uses SQLite. There is nothing special to configure.

**What is the Node.js version?**

```
docker exec <container-id> node --version
```

You can also see this information in the Dockerfile and in the Travis builds.


## Why forking the official Dockerfile?

I tweaked few elements like:

- Ghost container is running under [tini](https://github.com/krallin/tini#why-tini)
- A cleaner ENV VAR management
- Uninstall the `ghost cli` to safe few bytes in the docker image
- In the future, the image will support multi-stage build


## Contributing

The power of communities pull request and forks means that `1 + 1 = 3`. Help me make this repo a better one!

1. Fork it
2. Create your feature branch: `git checkout -b my-new-feature`
3. Commit your changes: `git commit -am 'Add some feature'`
4. Push to the branch: `git push origin my-new-feature`
5. Submit a pull request


## Copyright & License

- This fork is released under the **GNU** [license](https://github.com/pascalandy/GNU-GENERAL-PUBLIC-LICENSE).
- View **MIT** license information at:<br> https://ghost.org/license/ for the software.

As with all Docker images, these likely also contain other software which may be under different licenses (such as Bash, etc. from the base distribution, along with any direct or indirect dependencies of the primary software being contained).

Some additional license information which was able to be auto-detected might be found in the repo-info repository's ghost/ directory.

As for any pre-built image usage, it is the image user's responsibility to ensure that any use of this image complies with any relevant licenses for all software contained within.


## Sources & Fork

- **linear-build** — This Git repo is available [here](https://github.com/firepress-org/ghostfire). It’s based on the official [Ghost image](https://github.com/docker-library/ghost/tree/7eb6348d2a5493546577508d2cbae0a9922e1390/1/alpine)
- **multi-build** — A multi-build version might interest you:<br> https://github.com/mmornati/docker-ghostblog.


## About

- [Pascal Andy’s « now page »](https://pascalandy.com/blog/now/)
- Follow me on [Twitter](https://twitter.com/askpascalandy)
- Find more Ghost Themes on [play-with-ghost.com](https://play-with-ghost.com/)