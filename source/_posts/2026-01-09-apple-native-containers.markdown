---
layout: post
title:  "Apple native containers"
date:   2026-01-09
categories: macos containers
---

[container](https://github.com/apple/container) is a tool optimized for
Apple siliconthat you can use to create and run Linux containers
as lightweight virtual machines on your Mac.
The [Containerization](https://github.com/apple/containerization) Swift
package is used for low level container, image, and process management.

The tool consumes and produces
[OCI-compatible container images](https://github.com/opencontainers/image-spec),
so you can pull and run images from any standard container registry. You can push
images that you build to those registries as well, and run the images
in any other OCI-compatible application.
There's experimental support for
[using the tool with the VS Code Dev Containers extension](https://github.com/microsoft/vscode-remote-release/issues/11012).
Can it be a drop-in replacement for Docker?

### Installing native containers

It's possible to use `brew` for the installation, run the following command to install the Apple Container command-line tool.

```bash
brew install container
```

The CLI manages its own service; run this command to initialize and start the background system

```bash
container system start
```

Check the status of the service, and run `hello-world`.

```bash
container system status
container run hello-world
```

So far, so good!

![Hello world](/assets/images/2026-01-09-hello-world.jpg)

### Comparing the interface

Docker Desktop provides a lot of funcionality and unsurprisingly
`container` covers only a fraction of it. Comparing the output of
`docker help` and `container help` makes that immediately obvious.
The key question however is if the essential functions are there
and working as expected.

Let's compare the `container` subcommands with those exposed by
 `docker`.

| Apple Containers | Docker Desktop | Compatible | Remarks |
| --- | --- | :-: | --- |
| `build`: Build an image from a Dockerfile or Containerfile | `build`: Build an image from a Dockerfile | &#10003; | |
| `builder`: Manage an image builder instance | `builder`: Manage builds | &#10007; | Totally different purpose |
| `create`: Create a new container | `create`: Create a new container | &#10003; | |
| `delete`, `rm`: Delete one or more containers | `rm`: Remove one or more containers | &#10003; | |
| `exec`: Run a new command in a running container | `exec`: Execute a command in a running container | &#10003; | |
| `image`, `i`: Manage images | `image`: Manage images | &#10003; | The `images` subcommand doesn't exist tough |
| `inspect`: Display information about one or more containers | `inspect`: Return low-level information on Docker objects | &#10003; | Container info only, no other objects |
| `kill`: Kill or signal one or more running containers | `kill`: Kill one or more running containers | &#10003; | |
| `list`, `ls`: List running containers | `ps`: List containers | &#10007; | Different subcommand, but similar options |
| `logs`: Fetch container logs | `logs`: Fetch the logs of a container | &#10003; | |
| `network`, `n`: Manage container networks | `network`: Manage networks | &#10003; | |
| `registry`, `r`: Manage registry logins | `login`: Authenticate to a registry, `logout`: Log out from a registry |  &#10007; | Registry manages logins, similar to login/logout |
| `run`: Run a container | `run`: Create and run a new container from an image | &#10003; | |
| `start`: Start a container | `start`: Start one or more stopped containers | &#10003; | |
| `stats`: Display resource usage statistics for containers | `stats`: Display a live stream of container(s) resource usage statistics | &#10003; | |
| `stop`: Stop one or more running containers | `stop`: Stop one or more running containers | &#10003; | |
| `system`, `s`: Manage system components | `system`: Manage Docker | &#10003; | |
| `volume`, `v`: Manage container volumes | `volume`: Manage volumes | &#10003; | |

The standard options are there, but there's minor some differences in the interface.
It might be necessary to re-learn some
syntax, but it's nice to see that some
`container` subcommands have a shorter alias.

### Running a non-trivial workload

```bash
git clone https://github.com/JackBrenn/quakejs-rootless.git
cd quakejs-rootless
container build -t quakejs-rootless:latest .
container run -d \
  --name quakejs \
  -e HTTP_PORT=8080 \
  -p 8080:8080 \
  -p 27960:27960 \
  quakejs-rootless:latest
```

The only noticable difference was that `container` pulled
[BuildKit](https://github.com/moby/buildkit) before
starting to build the image