---
layout: post
title:  "Podman is better than Docker"
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

![Moby Vs Selkie](/assets/images/2026-10-11-moby-vs-selkie.jpg)

[Podman Vs Docker](https://www.xurrent.com/blog/podman-vs-docker-complete-2025-comparison-guide-for-devops-teams)

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
