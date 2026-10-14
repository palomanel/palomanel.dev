---
layout: post
title:  "Switching to Podman"
date:   2026-10-11
categories: containers podman docker development
---

Podman has been designed as a drop-in Docker replacement for most
CLI options and Open Container Initiative (OCI) image building.
However the architecture and key features differ, in most contexts Podman
is actually better!

Podman does not rely on a privileged background daemon and is able to run
rootless providing a better security stance. However you might run into trouble
for specific use cases, like binding to network ports below 1024, or using tools
that rely on proprietary Docker features.

In this post I compare both tools and provide and overview of how to get Podman
up and running for different operating systems.

## Docker Vs Podman

This picture of the Docker mascot and the Podman mascot in a Street Fighter
title screen was generated using AI, no animals were hurt!

![Moby Vs Selkie](/assets/images/2026-10-11-moby-vs-selkie.jpg)

The [Docker Engine](https://docs.docker.com/engine/)
was first released in 2013 and it was
quite disruptive at the time. Virtualization had finally taken hold as
much more practical way to manage your servers, and the concept of a
lightweight package that could be easily deployed anywhere immediately
proved useful.

The metaphor benind the project was powerful and simple. A shipping container
neatly isolates its contents (the goods being transported) from the logistical
chain (the vehicle that actually moves things around). A shipment of bananas
will travel by ship side by side with user electronics. Upon arriving to port
both containers are unloaded onto trucks that will take the load to their
final destination. You don't need special boats or trucks to carry bananas,
these vehicles just need to be prepared to carry containers.

A software container does the same: you package your software, then you deploy
it anywhere. From a developer machine to a cluster or a managed
serverless service. No more "but it worked on my machine", building and
distributing software became a lot easier. Beyond the great idea, the fact
Docker was Open Source greatly helped adoption.

Here's a view of the Docker architecture, inspired in the official
architecture diagram (original source: [docs.docker.com](https://docs.docker.com/get-started/docker-overview/)).
The architecture is a classical client-server pattern. The userspace client will
communicate a daemon that lives in privileged space.

![Docker Architecture](/assets/images/2026-10-11-docker-architecture.jpg)

Fast forward to today. Docker is not exactly Open Source anymore, but the
ecosystem has flourished.
The [Open Container Initiative (OCI)](https://opencontainers.org/)
handles the open industry standards around container formats and runtimes.
And there's a lot of tools that use those standards.

I'm interested in a tool that supports my local development workflow, and
I decided to make a comparison with [Podman](https://podman.io/). The fact
that it is fully Open Source but has a well established corporate sponsor
makes it a credible choice. Let's see how they fare against each other.

Let's have a look at the Podman architecture
(original source: [developers.redhat.com](https://developers.redhat.com/blog/2019/02/21/podman-and-buildah-for-docker-users)).
The main advantages are that it's daemonless and rootless. Containers are a
native Linux technology, so Podman excels there, for other operating
systems podman will actually need a virtual machine (exactly as Docker).

![Podman Architecture](/assets/images/2026-10-11-podman-architecture.jpg)

if we do a quick evaluation Podman actually wins in most of the dimensions.
With a more modern and secure architecture, while being compatible with
everything we've learned about using containers. Regarding performance
[Podman is faster in most operations](https://www.diva-portal.org/smash/get/diva2:1475598/FULLTEXT01.pdf)
although your experience may vary depending on your configuration and OS.

| Feature | Docker | Podman |
| --- | --- | --- |
| **Architecture** | Uses the `dockerd` daemon | Daemonless |
| **Security** | Requires root unless configured manually | Rootless by default, extra configuration required to bind an app to privileged ports (0-1023) |
| **Performance** | Startup ~1.2s, runtime memory ~100 Mb | Startup ~0.8s, runtime memory ~85 MB |
| **CLI** | `docker` | `podman` uses the same options as `docker` |
| **GUI** | Docker Desktop requires a paid license for Enterprise | Podman Desktop is free |
| **Orchestration** | `docker-compose` | `podman-compose` or `docker-compose` |

## Podman on Linux

### Installation and Usage

- [Rootless podman](https://oneuptime.com/blog/post/2026-01-27-podman-rootless/view)
- [Rootless podman 2](https://github.com/podman-container-tools/podman/blob/main/docs/tutorials/rootless_tutorial.md)

In rootless Podman, container UID 0 (root) is mapped to your host user's UID,
while other container UIDs map into your configured subuid range, isolating
the container from host root privileges. Docker's rootless mode also uses user
namespaces to map container root to an unprivileged host user, but Docker
traditionally required a root daemon unless rootless mode is explicitly enabled.

### Troubleshooting a rootless setup

There's a high chance that you will have problems with permissions when you bind
mount a volume in your container. The likely cause is that your UID in the host
is probably different from the uid inside the container. Docker suffers from
this issue as well, the good news are that Podman provides a solution!

The [podman unshare](https://docs.podman.io/en/latest/markdown/podman-unshare.1.html)
command allows users to run commands within a modified user namespace used by
rootless Podman containers.
When you execute `podman unshare`, your user’s UID and GID appear as 0 (root)
within the namespace.

This is the way to go when you need to perform operations that would
typically require root access, such as changing file ownership, or you need
have full control over the container's network stack.

Example commands:

- `podman unshare id`, displays the UID and GID inside the user namespace.
- `podman unshare cat /proc/self/uid_map`, shows UID mappings between the
  host and the namespace.
- `podman unshare chown 1000:1000 /workspace/volume`, changes ownership of a
  directory for container access, use the `uid:gid` that you will need inside
  the container.
- `podman unshare --rootless-netns ip addr`, show rootless netns information
  in user namespace for rootless containers.

The `unshare` command is not available for remote clients. The remote api does
not provide access to execute commands on the host directly.
If you want to use this use `podman machine ssh` to enter the vm.

## Podman on Mac

Containers rely on the Linux kernel. Because macOS and Windows do not use a
Linux kernel natively, Podman must spin up a small Linux virtual machine behind
the scenes to host and run container processes. Although the VM
adds very little overhead it still needs to be managed, you can choose what works
better for you:

1. Start and stop manually using the CLI
1. Start it [automatically using launchd](https://github.com/podman-container-tools/podman/blob/main/docs/tutorials/macos_autostart.md)
1. Let everything be handled by [Podman Desktop](https://podman-desktop.io/)

I personally dislike taskbar pollution and I want to maximize resources, so
I've defaulted to handling everything manually. The following snippet
on your terminal to have podman up and running in a few seconds.

```bash
brew install podman
brew install podman-compose
podman machine init
podman machine start
```

Just remember to use `podman machine start` whenever you need podman.
You can stop it using `podman machine stop`. Use `podman help machine`
to see a list of other commands or check the
[podman machine reference](https://docs.podman.io/en/stable/markdown/podman-machine.1.html)
for more information.
