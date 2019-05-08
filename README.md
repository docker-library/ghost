&nbsp;

<p align="center">
  <a href="https://firepress.org/">
    <img src="https://user-images.githubusercontent.com/6694151/50166045-2cc53000-02b4-11e9-8f7f-5332089ec331.jpg" width="340px" alt="FirePress" />
  </a>
</p>

<p align="center">
    <a href="https://firepress.org/">FirePress.org</a> |
    <a href="https://play-with-ghost.com/">play-with-ghost</a> |
    <a href="https://github.com/firepress-org/">GitHub</a> |
    <a href="https://twitter.com/askpascalandy">Twitter</a>
    <br /> <br />
    <a href="https://travis-ci.org/firepress-org/ghostfire">
        <img src="https://images.microbadger.com/badges/version/devmtl/ghostfire.svg" alt="version" />
    </a>
    <a href="https://hub.docker.com/r/devmtl/ghostfire">
        <img src="https://images.microbadger.com/badges/image/devmtl/ghostfire.svg" alt="Downloads" />
    </a>
    <a href="https://travis-ci.org/firepress-org/ghostfire">
        <img src="https://travis-ci.org/firepress-org/ghostfire.svg" alt="CICD build" />
    </a>
</p>

&nbsp;

# ghostfire


## What is this?

It’s a Docker image to run Ghost V2 in a container. Fully compatible with a simple `docker run`, Kubernetes or Docker Swarm.

**What is Ghost?** — Ghost is an open source software that lets you create your website with a blog. See the [FAQ section](https://play-with-ghost.com/ghost-themes/faq/#what-is-ghost) for more details.

Source: https://github.com/firepress-org/ghostfire


## Live Demo

Want to try Ghost quickly? This is for you!

[play-with-ghost.com](https://play-with-ghost.com/) is a playground to learn about Ghost. What's remarkable here, is that you have the option to log into the admin panel of each live demo available, by using dummy credentials.

In short, you can try Ghost on the spot without having to sign-up!

<br>

[![pwg-video-preview-e](https://user-images.githubusercontent.com/6694151/50233512-9bbc8a80-0381-11e9-83bb-f29a67000378.jpg)
](https://play-with-ghost.com/)

<br>


## Why forking the official Docker image?

We tweaked a few elements like:

1. Ghost container is running under [tini](https://github.com/krallin/tini#why-tini)
2. Easier to read Dockerfile with a cleaner ARG display
3. Uninstall the `ghost cli` to save some space in the final docker image
4. clean node cache
5. Added `curl` to do healthchecks

In the future, we plan to use a **multi-stage** build to slim down the image when Docker EE will supports it officially.


## How to use this image

**Requirement**: Ensure you have Docker installed on your machine. ([MAC OS X](https://hub.docker.com/editions/community/docker-ce-desktop-mac))

To run Ghost in a Docker container, here is the setup we are using in production. Just execute `runup.sh` bash script and you are good to go.

**Option #1 (Stateful)**

⚠️ warning — change the path `/myuser/localpath/ghost/content` and use the latest stable docker image.

```
GHOSTFIRE_IMG="devmtl/ghostfire:stable"

docker run -d \
—name ghostblog \
-p 2368:2368 \
-e url=http://localhost:2368 -e NODE_ENV=production \
-v /myuser/localpath/ghost/content:/var/lib/ghost/content \
${GHOSTFIRE_IMG}
```

**Option #2**:

```
GHOSTFIRE_IMG="devmtl/ghostfire:stable"

docker run -d \
—name ghostblog \
-p 2368:2368 \
-e url=http://localhost:2368 -e NODE_ENV=production \
${GHOSTFIRE_IMG}
```

**Option #3**:

- Run the script by typing: `./runup.sh`

#### Find the latest docker images tag 🐳

- **Docker hub** — https://hub.docker.com/r/devmtl/ghostfire/tags/
- **Travis** — https://travis-ci.org/firepress-org/ghostfire

I'm surprised that at this point, it's been pulled more than **11 millions of time**!

![docker-hub](https://user-images.githubusercontent.com/6694151/53067692-4c8af700-34a3-11e9-9fcf-9c7ad169a91b.jpg)


#### master branch (stable) tags 🐳

I recommend using the tag from this format: $IMAGE_SHA_SHORT:

```
devmtl/ghostfire:2.9.1-99814a4
```

But if you prefer, you can use:

```
devmtl/ghostfire:2.9.1
devmtl/ghostfire:stable
```


#### edge branch (not stable) tags 🐳

```
devmtl/ghostfire:edge-2.9.1-7d64db0
devmtl/ghostfire:edge-2.9.1
devmtl/ghostfire:edge
```


### Edge VS Master

⚠️ Workflow warning. You would expect that we would merge `edge` into `master`. We don’t do this. Instead, think of it as independent projects. The main reason is because the **.travis.yml is not the same in those two branches**.

Let’s understand our process.

Because we run a lot of websites in production using this image, we prefer to do my UAT (tests) using a dedicated `edge` branch. **In other words, it’s a manual checkpoint to avoid a crash at scale.**

It also has the advantage of keeping a clean commit history in the master branch (without doing git-fu all the time).

Once we confirm the edge build is a PASS, we update the Dockerfile in `master` branch as well. At this point, we are entirely confident the docker image is working correctly.


#### Well tested

DevOps best practices are essential to us. Many checkpoints ensure this Docker image for Ghost software runs smoothly.

[In this post](https://firepress.org/en/software-and-ghost-updates/), we explain how we deploy Ghost in production and which best practices we do follow.


## Developing Ghost themes locally

I open sourced [my setup here](https://github.com/firepress-org/ghost-local-dev-in-docker). It’s a workflow to run Ghost locally within a Docker container. Once your local paths are defined, it’s enjoyable and easy to work **between many themes**.


## Random stuff

**Breaking change**. If you still run Ghost 0.11.xx, be aware of the container's path difference.

```
- Ghost 2.x.x is: /var/lib/ghost/content
- Ghost 1.x.x is: /var/lib/ghost/content
- Ghost 0.11.x is: /var/lib/ghost
```

**SQLite Database**

This Docker image for Ghost uses SQLite. There is nothing special to configure.

**What is the Node.js version?**

We follow the latest Node supported version. See this in the Dockerfile.

```
docker exec <container-id> node --version
```

You can also see this information in the Dockerfile and in the Travis builds.


## Services

## FirePress Hosting

**At FirePress we do one thing and we do it with our whole heart: we host fully managed Ghost’s websites**. The idea behind FirePress is to empower freelancers and small organizations to be able to build an outstanding mobile-first website.

Because we believe your website should speak up in your name, we consider our mission completed once your site has become [your impresario](https://firepress.org/en/why-launching-your-next-website-with-firepress/). Start your [free trial here](https://firepress.org/en/10-day-free-trial/). 

#### Workshop

We also offer a workshop where participants end up with a website/blog they can smoothly operate themselves. The workshops are available in:

- [Montréal - Canada](https://firepress.org/en/workshop/)


## Contributing

The power of communities pull request and forks means that `1 + 1 = 3`. You can help to make this repo a better one! Here is how:

1. Fork it
2. Create your feature branch: `git checkout -b my-new-feature`
3. Commit your changes: `git commit -am 'Add some feature'`
4. Push to the branch: `git push origin my-new-feature`
5. Submit a pull request

Check this post for more details: [Contributing to our Github project](https://pascalandy.com/blog/contributing-to-our-github-project/). Also, by contributing you agree to the [Contributor Code of Conduct on GitHub](https://pascalandy.com/blog/contributor-code-of-conduct-on-github/). It's plain common sense really.

<br>


## License

- This git repo is under the **GNU V3** license. [Find it here](https://github.com/pascalandy/GNU-GENERAL-PUBLIC-LICENSE/blob/master/LICENSE.md).
- The Ghost’s software is under the **MIT** license. [Find it here](https://ghost.org/license/).

<br>


## Sources & Fork

- This Git repo is available at [https://github.com/firepress-org/ghostfire](https://github.com/firepress-org/ghostfire)
- Forked from the [official](https://github.com/docker-library/ghost/) Ghost image

<br>


## Why all this work?

Our [mission](https://firepress.org/en/our-mission/) is to empower freelancers and small organizations to build an outstanding mobile-first website.

Because we believe your website should speak up in your name, we consider our mission completed once your site has become your impresario.

For more info about the man behind the startup, check out my [now page](https://pascalandy.com/blog/now/). You can also follow me on Twitter [@askpascalandy](https://twitter.com/askpascalandy).

— The FirePress Team 🔥📰
