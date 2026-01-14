---
layout: post
title:  "Apple native containers"
date:   2026-01-09
categories: macos containers
---

In [WWDC 2025](https://developer.apple.com/videos/play/wwdc2025/346/)
(June 2025) Apple announced [container](https://github.com/apple/container),
it's a tool optimized for Apple silicon
that you can use to create and run Linux containers
as lightweight virtual machines on your Mac.
The [Containerization](https://github.com/apple/containerization) Swift
package is used for low level container, image, and process management.

The tool consumes and produces
[OCI-compatible container images](https://github.com/opencontainers/image-spec),
so you can pull and run images from any standard container registry. You can push
images that you build to those registries as well, and run the images
in any other OCI-compatible application. At the time I'm writing this
there's only experimental support for
[using the tool with the VS Code Dev Containers extension](https://github.com/microsoft/vscode-remote-release/issues/11012).

Quoting from the [container Technical Overview](https://github.com/apple/container/blob/main/docs/technical-overview.md) to highlight the main architecture difference:

> Many operating systems support containers, but the most commonly encountered
> containers are those that run on the Linux > operating system. With macOS,
> the typical way to run Linux containers is to launch a Linux virtual machine
> (VM) that hosts all of your containers.
>
> container runs containers differently. Using the open source
> Containerization package, it runs a lightweight VM for each container that
> you create. This approach has the following properties:
>
> * Security: Each container has the isolation properties of a full VM,
> using a minimal set of core utilities and dynamic libraries to reduce
> resource utilization and attack surface.
> * Privacy: When sharing host data using container, you mount only necessary
> data into each VM. With a shared VM, you need to mount all data that you may
> ever want to use into the VM, so that it can be mounted selectively into
> containers.
> * Performance: Containers created using container require less memory than
> full VMs, with boot times that are comparable to containers running in a shared
> VM.

I was curious to see how Apple Native Containers fared against
Docker so I ran a few tests. Here's the **TL;DR** on what I found:

* Design choices translate into very real differences that might
make the tool useful for you, or not... the more permissive license can also
be a big plus.
* Apple Native Containers work as expected and provide the necessary basic
functionality to run and manage containers in a modern Mac,
however it is not a drop-in replacement for Docker.

### Installing native containers

It's possible to use `brew` for the installation, run the following command
to install the Apple Container command-line tool.

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
It might be necessary to re-learn some syntax, but it's nice to see that some
`container` subcommands have a shorter alias.

### Building and running a non-trivial workload

Time to build an run a containerized workload.
I got inspired by a [Christmas post I've seen on another blog](https://blog.nuneshiggs.com/quakejs-rootless-prontos-para-as-ferias-de-natal/), and
decided to pick up something fun. Let's start with
the [QuakeJS Rootless Project](https://github.com/JackBrenn/quakejs-rootless)
from [JackBrenn](https://github.com/JackBrenn). The project
enables palying multiplayer Quake III Arena in a browser with
Podman / Docker. Let's see if it works with `container`. The commands
are exactly the same for `docker`, so comparing was easy.

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

Starting from scratch to compare the build times
between `docker` and `container` both clocked very similar times,
around 90 seconds. Which makes sense, given they're both
using the same engine to build their images.
([BuildKit](https://github.com/moby/buildkit)) is an improved backend
that replaced the legacy Docker builder and it's the
[default builder](https://docs.docker.com/build/buildkit/)
for users on Docker Desktop, and Docker Engine as of
version `23.0`.
The only difference I was able to spot in the output
is that `container` pulled the BuildKit image before
starting to build the image.

The `run` step will start a completely local QuakeJS server
running in a container in the background.
Besides running the server engine which hosts the gameworld
for several players, it will serve
a [WASM](https://webassembly.org/) version of Quake III
compiled using [emscripten](https://emscripten.org/).
No external dependencies, no content servers, no proxies -
just pure Quake III Arena gaming in your browser.
You can use this to host a LAN party anywhere! Point
to `localhost:8080` and accept the EULA:

![QuakeJS EULA](/assets/images/2026-01-09-QuakeJS-EULA.png)

And after downloading the necessary data files you'll be
ready for [fragging](https://hackersdictionary.com/html/entry/frag.html)
your friends or co-workers.

![QuakeJS in the browser](/assets/images/2026-01-09-QuakeJS-browser.png)

Checking the stats in Activity Monitor the observations seems to be
consistent with what we now about each tool's architecture. It seems
Docker reserved a lot of memory for one big virtual machine.

| Process | Real Memory Size | CPU usage |
| --- | --: | --: |
| Virtual Machine Service for container-runtime-linux | 1.00 Gb | ~28% |
| Virtual Machine Service for Docker | 6.85 Gb | ~28% |
