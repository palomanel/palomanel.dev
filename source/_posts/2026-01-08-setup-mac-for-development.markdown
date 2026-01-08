---
layout: post
title:  "Setting up a Mac as development machine"
date:   2026-01-08
categories: jekyll update
---

This is a quick and and opinionated guide to prepare a Mac for development work.
The main purpose of the guide is collecting fragmented information that can be
found scattered around the web.

This document is provided “AS IS”, without any guarantee of any kind. Keep in
mind that some of the software mentioned here might have changed the options or
defaults since the time of writing.

### Install Apple developer tools

The [Apple Developer Tools](https://en.wikipedia.org/wiki/Apple_Developer_Tools)
are a suite of software tools from Apple to aid in making software dynamic
titles for the macOS and iOS platforms.

One of the main tools in the bundle is Xcode, which is also available as
a free download from the Mac App Store. However there's a lot of other useful tools
included, the main one being `git`.

This pulls the Apple developer tools:

```bash
xcode-select --install
```

## Configure Secure Shell Protocol

The Secure Shell Protocol ([SSH Protocol](https://en.wikipedia.org/wiki/Secure_Shell)) 
continues to be the standard for operating network services over unsecured
networks. It is also the most convenient protocol for securing git
connections.

Create a key pair using the `ed25519` elliptic curve algorithm.
Known for fast signing and verification, should be ready for [Post-quantum cryptography](https://en.wikipedia.org/wiki/Post-quantum_cryptography).

When prompted, enter a strong passphrase, then add the passphrase to the Apple keychain:

```bash
ssh-keygen -t ed25519 -C "example@mail.com"
ssh-add --apple-use-keychain ~/.ssh/id_ed25519
```

Configure the MacOS [SSH-agent](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent)
to always use the Keychain in `~/.ssh/config`:

- The `AddKeysToAgent yes` entry loads the SSH-agent
- You can add an `IdentifyFile` for each of your private keys
- The `UseKeychain yes` entry tells SSH to look in your OSX keychain for the key passphrase

Example:

```bash
cat <<EOF >> ~/.ssh/config
Host *
    AddKeysToAgent yes
    UseKeychain yes
    IdentityFile ~/.ssh/id_ed25519
EOF
```

Configure your shell to load the Keychain whenever an interactive session is started.

```bash
echo "ssh-add --apple-load-keychain -q" >> ~/.zshrc
```

### Configure Git

[Git](https://en.wikipedia.org/wiki/Git) is a distributed version control
system, that is capable of managing versions of source code or data.
It is the most popular distributed version control system.

There are platforms offering Git repository services, including GitHub,
SourceForge, Bitbucket and GitLab. However you can use git independently,
the full project history is stored local database that can be synced with
other peers when desired.

Start by setting your basic info:

```bash
git config --global user.name "John Doe"
git config --global user.email "example@mail.com"
```

You should also configure git to sign your commits:

```bash
git config --global gpg.format ssh
git config --global user.signingkey "key::$(cat ~/.ssh/id_ed25519.pub)"
git config --global commit.gpgsign true
git config --global tag.gpgsign true
mkdir -p ~/.config/git
echo "example@mail.com $(cat ~/.ssh/id_ed25519.pub)" > ~/.config/git/allowed-signers
git config --global gpg.ssh.allowedSignersFile "~/.config/git/allowed-signers"
```

### Install homebrew

[Homebrew](https://brew.sh/) is an open-source package manager for macOS (and nowadays Linux).
It simplifies the installation of software packages by providing a simple CLI interface,
no more drag and drop to install tools. Removing packages is just as easy.

Homebrew installs packages to their own directory and then symlinks their files
into /opt/homebrew (on Apple Silicon). It won’t install files outside its prefix and
you can place a Homebrew installation wherever you like. That means you can
organize your system in any way you want.

The script installer explains what it will do and then pauses before it does it.
There is also a `.pkg` installer nowadays, you can download it from
[Homebrew's latest GitHub release](https://github.com/Homebrew/brew/releases/latest).
The easiest way is just running:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
echo 'eval $(/opt/homebrew/bin/brew shellenv)' >> ~/.zprofile
```

### Install Alacritty

Alacritty is a modern terminal emulator that comes with sensible defaults, but allows
for extensive [configuration](https://github.com/alacritty/alacritty#configuration).
By integrating with other applications, rather than reimplementing their functionality,
it manages to provide a flexible set of [features](https://github.com/alacritty/alacritty/blob/master/docs/features.md)
with high performance. The supported platforms currently consist of BSD, Linux, macOS
and Windows.

The software is considered to be at a beta level of readiness; there are a few missing
features and bugs to be fixed, but it is already used by many as a daily driver.

Precompiled binaries are available from the GitHub [releases page](https://github.com/alacritty/alacritty/releases).

Mac OSX will refuse to run the app as the binary is not currently signed, to be able
to use Alacritty it will be necessary to tweak its file attributes.

```bash
xattr -dr com.apple.quarantine "/Applications/Alacritty.app"
```

### Install Docker

Docker is an open platform for developing, shipping, and running applications.
It enables you to separate your applications from your infrastructure
so you can deliver software quickly by using operating-system-level
virtualization to deliver software in packages called containers.

The Docker Engine is licensed under the Apache License 2.0. Docker
Desktop distributes some components that are licensed under the GNU
General Public License. Docker Desktop is free for personal use,
small businesses (fewer than 250 employees AND less than $10 million
in annual revenue), education, and non-commercial open-source projects.
For all other commercial use, a paid subscription is required.

Docker Compose is a simple tool for defining and running multi-container
applications. It is often used to define simulate complex architectures
in a developer machine.

Installing Docker Desktop is an easy way to set-up the Docker daemon on
Mac OSX, you also might want to install docker-desktop:

```bash
brew install --cask docker-desktop
brew install docker-compose
```

### Install and Configure VS Code

Visual Studio Code (commonly referred to as VS Code) is an integrated
development environment developed by Microsoft for Windows, Linux, macOS
and web browsers. Features include support for debugging, syntax highlighting, 
intelligent code completion, snippets, code refactoring, and embedded version
control with Git. Users can change the theme, keyboard shortcuts and
preferences, as well as install extensions that add functionality, including
to extend its capabilities to function as an IDE for other languages.

Visual Studio Code is proprietary software released under the "Microsoft
Software License", but based on the MIT licensed program named [Visual Studio Code
– Open Source](https://github.com/microsoft/vscode).

Install VS Code using brew, then you can then install any extensions you need,
like the [DevContainers](https://containers.dev/) extension.

```bash
brew install --cask visual-studio-code
code --install-extension ms-vscode-remote.remote-containers
```
