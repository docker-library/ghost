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
</p>

&nbsp;

# [ghostfire](https://github.com/firepress-org/ghostfire)

<br>

## What is this?

**What is Ghost?** — Ghost is an open-source software that lets you create your website with a blog. See the [FAQ section](https://play-with-ghost.com/ghost-themes/faq/#what-is-ghost) for more details. This project makes it run in a Docker image.

<br>

## Docker image features :

- [x] **Multi-stage builds** with aggressive optimization
- [x] **Security-focused**: Non-root user execution with `gosu` privilege dropping
- [x] **Multi-architecture support**: `linux/amd64`, `linux/arm64`, `linux/arm/v7`
- [x] **Production-ready**: `config.production.json` template with best practices
- [x] **Alpine Linux base** for minimal attack surface (we don't maintain debian)
- [x] **Health checks** with `curl` support
- [x] **Labels** based on the OpenContainer standard
- [x] **Conditional dependencies**: Smart installation of `sharp` and `sqlite3`
- [x] **Enterprise-grade**: Optimized for Docker Swarm deployments

We achieve significant size optimization through multi-stage builds and aggressive cleanup:

```
devmtl/ghostfire:stable                ~320MB (optimized)
ghost:5.x-alpine                       ~380MB (official)
```

<br>

## GitHub Actions CI/CD :

[![ci status](https://github.com/firepress-org/ghostfire/actions/workflows/ghostv5.yml/badge.svg?branch=master)](https://github.com/firepress-org/ghostfire/actions/workflows/ghostv5.yml)

- [x] **Multi-architecture builds**: `linux/amd64`, `linux/arm64`, `linux/arm/v7`
- [x] **Comprehensive security scanning**: Snyk, Dockle, Trivy vulnerability detection
- [x] **Performance testing**: Lighthouse audits (localhost and online)
- [x] **Quality assurance**: Linting using `super-linter`
- [x] **Automated deployment**: Continuous deployment to Docker Swarm clusters
- [x] **Smart caching**: Build cache optimization for faster CI/CD
- [x] **Notification system**: Slack notifications for build status
- [x] **Shared variables**: Efficient job coordination and data sharing
- [x] **Best practices**: Following [enterprise DevOps standards](https://firepress.org/en/how-do-we-update-hundreds-of-ghosts-websites-on-docker-swarm/)
- [x] **Extreme visibility**: Comprehensive logging and monitoring during builds

![CI_2021-10-03_17h42](https://user-images.githubusercontent.com/6694151/135772462-0c39fe73-be9e-4aa3-8103-b1c849c0c41f.jpg)

<br>

## Live Demo

Want to try Ghost quickly? This is for you!

[play-with-ghost.com](https://play-with-ghost.com/) is a playground to learn about Ghost. What's remarkable here, is that you have the option to log into the admin panel of each live demo available, by using dummy credentials.

In short, you can try Ghost on the spot without having to sign-up!

<br>

[![pwg-video-preview-e](https://user-images.githubusercontent.com/6694151/50233512-9bbc8a80-0381-11e9-83bb-f29a67000378.jpg)
](https://play-with-ghost.com/)

<br>

#### Continuous integration

See [Github Actions sections](https://github.com/firepress-org/ghostfire/actions)

At this point, this docker image has been pulled more than **11 millions of time**!

![docker-hub](https://user-images.githubusercontent.com/6694151/53067692-4c8af700-34a3-11e9-9fcf-9c7ad169a91b.jpg)

## Quick Start

#### Option #1 (basic run)

```bash
GHOSTFIRE_IMG="devmtl/ghostfire:stable"

docker run -d \
  --name ghostblog \
  -p 2368:2368 \
  -e url=http://localhost:2368 \
  ${GHOSTFIRE_IMG}
```

#### Option #2 (production with persistent data)

```bash
GHOSTFIRE_IMG="devmtl/ghostfire:stable"

docker run -d \
  --name ghostblog \
  -p 2368:2368 \
  -e url=http://localhost:2368 \
  -v /myuser/localpath/ghost/content:/var/lib/ghost/content \
  -v /myuser/localpath/ghost/config.production.json:/var/lib/ghost/config.production.json \
  ${GHOSTFIRE_IMG}
```

#### Option #3 (development with health checks)

```bash
GHOSTFIRE_IMG="devmtl/ghostfire:stable"

docker run -d \
  --name ghostblog \
  -p 2368:2368 \
  -e url=http://localhost:2368 \
  -e NODE_ENV=development \
  --health-cmd="curl -f http://localhost:2368/ || exit 1" \
  --health-interval=30s \
  --health-timeout=10s \
  --health-retries=3 \
  -v $(pwd)/content:/var/lib/ghost/content \
  ${GHOSTFIRE_IMG}
```

To configure the `config.production.json` refer the [ghost docs](https://docs.ghost.org/concepts/config/).

#### master branch (stable) tags 🐳

For the **stable** branch, I recommend using the tag from the **first line**:

```
devmtl/ghostfire:stable_5.120.4_<hash>_<date>
devmtl/ghostfire:stable_5.120.4
devmtl/ghostfire:stable
```

Find the latest tags on **DockerHub** here:
[https://hub.docker.com/r/devmtl/ghostfire/tags/](https://hub.docker.com/r/devmtl/ghostfire/tags/)

#### edge branch (dev) tags 🐳

This is reserved for development and testing.

```
devmtl/ghostfire:edge_5.120.4_<hash>_<date>
devmtl/ghostfire:edge_5.120.4
devmtl/ghostfire:edge
```

## Architecture & Security

### Multi-Stage Build Process

Our Dockerfile uses a sophisticated 4-stage build process:

1. **`mynode`** - Base Node.js environment with security tools (gosu, timezone setup)
2. **`debug`** - Package version debugging and validation layer
3. **`builder`** - Ghost installation and native dependency compilation
4. **`final`** - Minimal runtime image with only necessary components

### Security Features

- **Non-root execution**: Runs as `node` user for enhanced security
- **Privilege dropping**: Uses `gosu` for secure step-down from root
- **File permissions**: Proper ownership and permission management
- **Minimal attack surface**: Alpine Linux base with aggressive cleanup
- **Vulnerability scanning**: Integrated security scanning in CI/CD

### Volume Management

Critical paths for data persistence:

```bash
/var/lib/ghost/content              # All Ghost content, themes, uploads
/var/lib/ghost/config.production.json  # Runtime configuration
/var/lib/ghost/content/logs         # Application logs
/var/lib/ghost/content/data/ghost.db    # SQLite database
```

<br>

## DevOps best practices

Let's understand our processes. In this post « [How we update hundreds of Ghost's websites on Docker Swarm?](https://firepress.org/en/how-we-update-hundreds-of-ghosts-websites-on-docker-swarm/) », we explain how we deploy Ghost in production and which best practices we do follow.

## Enhanced unit tests during the CI

![unit-test-a](https://user-images.githubusercontent.com/6694151/61649557-b80a0800-ac7f-11e9-85b7-425e5456cb2d.jpg)
<br>
![unit-test-b](https://user-images.githubusercontent.com/6694151/61649559-b80a0800-ac7f-11e9-9154-cd6f5264af71.jpg)
<br>
![unit-test-c](https://user-images.githubusercontent.com/6694151/61649558-b80a0800-ac7f-11e9-9638-4b3241e4dcee.jpg)

<br>

## Developing Ghost themes locally

I open-sourced [my setup here](https://github.com/firepress-org/ghost-local-dev-in-docker). It’s a workflow to run Ghost locally within a Docker container. Once your local paths are defined, it’s enjoyable and easy to work **between many themes**.

<br>

## Configuration & Database

### Database Support

- **SQLite** (default): Zero-configuration, file-based database at `/var/lib/ghost/content/data/ghost.db`
- **MySQL**: Full support with connection configuration in `config.production.json`

### Configuration Management

Ghost configuration is handled via `config.production.json` with these key areas:

- **Database connection**: SQLite default or MySQL configuration
- **Mail configuration**: SMTP/Mailgun templates provided
- **Logging**: 7-day retention with 5-day rotation
- **Content paths**: Mapped to `/var/lib/ghost/content`
- **URL configuration**: Flexible URL and SSL settings

Check versions in running container:
```bash
docker exec <container-id> node --version
docker exec <container-id> ghost --version
```


<br>

## FirePress Hosting

At FirePress we empower entrepreneurs and small organizations to create their websites on top of [Ghost](https://firepress.org/en/faq/#what-is-ghost).

At the moment, our **pricing** for hosting one Ghost website is $15 (Canadian dollars). This price will be only available for our first 100 new clients, starting May 1st, 2019 🙌. [See our pricing section](https://firepress.org/en/pricing/) for details.

More details [about this announcement](https://forum.ghost.org/t/host-your-ghost-website-on-firepress/7092/1) on Ghost's forum.

<br>

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
