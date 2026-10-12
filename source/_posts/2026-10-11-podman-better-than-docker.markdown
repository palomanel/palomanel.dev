---
layout: post
title:  "Podman is better than Docker"
date:   2026-09-18
categories: containers podman docker development
---

- [Rootless podman](https://oneuptime.com/blog/post/2026-01-27-podman-rootless/view)
- [Rootless podman 2](https://github.com/podman-container-tools/podman/blob/main/docs/tutorials/rootless_tutorial.md)

In rootless Podman, container UID 0 (root) is mapped to your host user's UID,
while other container UIDs map into your configured subuid range, isolating
the container from host root privileges. Docker's rootless mode also uses user
namespaces to map container root to an unprivileged host user, but Docker
traditionally required a root daemon unless rootless mode is explicitly enabled.

## Overview of Podman Unshare

The [podman unshare](https://docs.podman.io/en/latest/markdown/podman-unshare.1.html)
command that allows users to run commands within a modified
user namespace used by rootless Podman containers. This feature is particularly
useful for troubleshooting and managing permissions related to files and
directories that are bind-mounted into containers.

When you execute `podman unshare`, your user’s UID and GID appear as 0 (root)
within the namespace. This allows you to perform operations that would
typically require root access, such as changing file ownership.

Common Use Cases

- Fixing Permissions: If a container cannot access a bind-mounted directory
  due to permission issues, you can use podman unshare to change the ownership
  of that directory to match the UID of the user running the container.
- Debugging: It helps in diagnosing issues related to file access and ownership
  that may not be visible from the host system.

Example commands

- `podman unshare id`, displays the UID and GID inside the user namespace.
- `podman unshare cat /proc/self/uid_map`, shows UID mappings between the
  host and the namespace.
- `podman unshare chown 1000:1000 /workspace/volume`, changes ownership of a
  directory for container access.
- `podman unshare --rootless-netns ip addr`, show rootless netns information
  in user namespace for rootless containers.
