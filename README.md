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

[play-with-ghost.com](https://play-with-ghost.com/) is a playground to learn about Ghost. What's remarkable here, is that you have the option to log in into the admin panel of each live demo available, by using dummy credentials.

In short, you can try Ghost on the spot without having to sign-up!

<br>

[![pwg-video-preview-e](https://user-images.githubusercontent.com/6694151/50233512-9bbc8a80-0381-11e9-83bb-f29a67000378.jpg)
](https://play-with-ghost.com/)

<br>

#### Explainer video

[![pwg-video-preview-b](https://user-images.githubusercontent.com/6694151/50162583-bc66e080-02ac-11e9-937f-741f6d388d40.jpg)](https://play-with-ghost.com/#video)


## Why forking the official Docker image?

We tweaked a few elements like:

- Ghost container is running under [tini](https://github.com/krallin/tini#why-tini)
- Easier to read Dockerfile with a cleaner envvar display
- Uninstall the `ghost cli` to save some space in the final docker image
- Added `curl` to do healthcheck

In the future, we plan to use a multi-stage build to slim down the image


## How to use this image

**Requirement**: Ensure you have Docker installed on your machine. ([MAC OS X](https://hub.docker.com/editions/community/docker-ce-desktop-mac))

To run Ghost in a Docker container, here is the setup we use in production. Just execute `runup.sh` bash script and you are good to go.

**Option #1** _(prefered)_:

- Run the script by typing: `./runup.sh`

**Option #2**:

```
GHOSTFIRE_IMG="devmtl/ghostfire:stable"

docker run -d \
—name ghostblog \
-p 2368:2368 \
-e url=http://localhost:2368 -e NODE_ENV=production \
${GHOSTFIRE_IMG}
```

**Option #3 (Stateful)**

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


### master branch (stable) tags 🐳

I recommend using the tag from this format: $IMAGE_SHA_SHORT

```
devmtl/ghostfire:2.9.1-99814a4
devmtl/ghostfire:2.9.1
devmtl/ghostfire:stable
```


### edge branch (not stable) tags 🐳

```
devmtl/ghostfire:edge-2.9.1-7d64db0
devmtl/ghostfire:edge-2.9.1
devmtl/ghostfire:edge
```


### Latest docker images 🐳

- **Docker hub** — https://hub.docker.com/r/devmtl/ghostfire/tags/
- **Travis** — https://travis-ci.org/firepress-org/ghostfire


### Edge VS Master

⚠️ Workflow warning. You would expect that we merge `edge` into `master`. We don’t do this. Think of it as two independent projects. The main reason for this is the fact that **the two .travis.yml files don’t push the same docker images** (stable VS edge).

Let’s understand our process.

Because we run a lot of websites in production using this image, we prefer to do UAT (tests) using a dedicated `edge` branch. Few sites (a cohort of all site we manage) deploy automatically every update on edge. **It’s a manual checkpoint that helps us avoiding crashing websites at scale**. It also has the advantage to keep a clean commit history (without doing git-fu all the time).

Once we confirm the edge build is a PASS, we update the Dockerfile in `master` branch as well. At this point, we are entirely confident the docker image is working correctly and deploy every site we manage.


## Developing Ghost themes locally

I open sourced [my setup here](https://github.com/firepress-org/ghost-local-dev-in-docker). It’s a workflow to run Ghost locally within a Docker container. Once your local paths are defined, it’s enjoyable and easy to work **between many themes**.


## Random

**Breaking change**

- Ghost 2.x.x is: /var/lib/ghost/content
- Ghost 1.x.x is: /var/lib/ghost/content
- Ghost 0.11.x is: /var/lib/ghost

_If you still run Ghost 0.11.xx, be aware of the container's path difference._

**SQLite Database**

This Docker image for Ghost uses SQLite. There is nothing special to configure.

**What is the Node.js version?**

```
docker exec <container-id> node --version
```

You can also see this information in the Dockerfile and in the Travis builds.


## Services

#### Hosting

**At FirePress we do one thing and we do it with our whole heart: we host fully managed Ghost’s websites**. The idea behind FirePress is to empower freelancers and small organizations to be able to build an outstanding mobile-first website.

Because we believe your website should speak up in your name, we consider our mission completed once your site has become [your impresario](https://firepress.org/en/why-launching-your-next-website-with-firepress/). Start your [free trial here](https://firepress.org/en/10-day-free-trial/). 


#### Workshop

We also offer a workshop where participants end up with a website/blog they can smoothly operate themselves. Details are coming soon. The workshops will be available in those cities:

- Montréal - Canada
- Toronto - Canada
- Québec City - Canada
- New-York - USA

## Contributing

The power of communities pull request and forks means that `1 + 1 = 3`. Help me make this repo a better one!

1. Fork it
2. Create your feature branch: `git checkout -b my-new-feature`
3. Commit your changes: `git commit -am 'Add some feature'`
4. Push to the branch: `git push origin my-new-feature`
5. Submit a pull request


## Copyright & License

- This git repo is under the **GNU** license information. [Find it here](https://github.com/pascalandy/GNU-GENERAL-PUBLIC-LICENSE).
- The Ghost’s software is under the **MIT** license. [Find it here](https://ghost.org/license/).


## Sources & Fork

- This Git repo is available at [https://github.com/firepress-org/ghostfire](https://github.com/firepress-org/ghostfire)
- Forked from the [official](https://github.com/docker-library/ghost/) Ghost image

## Keep in touch

- My [« now page »](https://pascalandy.com/blog/now/)
- Follow me on [Twitter](https://twitter.com/askpascalandy)

P.S. As you might see, I’m not a native English speaker. If something sounds funny, please let me know.  Just [open an issue](https://github.com/firepress-org/ghostfire/issues). Thank you!

Cheers!