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
