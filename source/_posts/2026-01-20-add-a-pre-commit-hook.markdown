---
layout: post
title:  "Adding pre-commit hooks"
date:   2026-01-20
categories: devops update tooling
---

Git hook scripts are useful for identifying simple issues before submission
to code review. Run hooks on every commit to automatically point out
issues in code such as missing semicolons, trailing whitespace, and debug
statements. Ensuring these issues are detected in a developer's local clone
makes pull requests easier to review, and allows everyone working on the
project to be more productive by focusing on needed changes instead of dealing
with inconsistencies in the code base.

This post will delve on how to install and configure
[pre-commit](https://pre-commit.com/), a framework for managing and maintaining
multi-language pre-commit hooks.
There are a lot of [supported hooks](https://pre-commit.com/hooks.html)
available, and what to include depends on the project type,
programming languages being used, and team maturity. As an example I will use
this blog's tooling, and add hooks that improve my writing workflow by
detecting potential issues as early as possible.

## Installing pre-commit

Before you can run hooks, you need to have the `pre-commit` package installed.
There's several options for installation, depending on your project type and
preference:

**Using a python package manager**, like [pip](https://pypi.org/project/pip/) or
[pipx](https://github.com/pypa/pipx):

```bash
pip install pre-commit
```

**In a python project** add the following to your `requirements.txt`
(or `requirements-dev.txt`):

```bash
pre-commit
```

**As a 0-dependency**
[zipapp](https://docs.python.org/3/library/zipapp.html):

- locate and download the `.pyz` file from the
  [pre-commit github project releases](https://github.com/pre-commit/pre-commit/releases)
- run `python pre-commit-#.#.#.pyz` ... in place of `pre-commit ...`

**If you're using devcontainer** you can add it as a
[feature](https://containers.dev/features)
to your `devcontainer.json`:

```json
    "features": {
      "ghcr.io/prulloac/devcontainer-features/pre-commit:1.0.3": {}
    },
```

## Configuring pre-commit

Once you have pre-commit installed, adding pre-commit plugins to your project
is done with the `.pre-commit-config.yaml` configuration file.
The pre-commit config file describes what repositories and hooks are installed,
and the stage they will run in (`pre-commit`, `pre-push`, etc).

```bash
pre-commit sample-config > .pre-commit-config.yaml
````

The generated file will be something like this

```yml
# See https://pre-commit.com for more information
# See https://pre-commit.com/hooks.html for more hooks
repos:
-   repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v3.2.0
    hooks:
    -   id: trailing-whitespace
    -   id: end-of-file-fixer
    -   id: check-yaml
    -   id: check-added-large-files
```

Once you have a configuration register with with `git` using:

```bash
pre-commit install
```

When you add a `pre-commit` hook to your project it's a good idea to run the
hooks against all the files. Typically hooks will only run on the changed
files, but this allows you understand the current status and any improvements
currently needed.

```bash
pre-commit run --all-files
```

You can update your hooks to the latest version automatically by running
`pre-commit autoupdate`. By default, this will bring the hooks to the latest
tag on the default branch. It's a good idea to run this regularly to get
fixes and improvements to your hooks.

## Fine-tuning for this blog

I used `pre-commit sample-config` to seed the configuration as shown above.
Then I added the feature to my `devcontainer.json` file, I also made sure that
`pre-commit` was registered in the `postCreateCommand`. Here are the relevant
changes to `devcontainer.json`:

```json
  // Features to add to the dev container.
  // More info: https://containers.dev/features.
    "features": {
      "ghcr.io/prulloac/devcontainer-features/pre-commit:1.0.3": {}
      },

  // Run commands after the container is created.
  "postCreateCommand": "pre-commit install",
```

After ensuring my hooks were running as expected inside my devcontainer
I proceeded to install a few extra plugins that made sense for this project.
Let's go over them:

**Secret Scanning** is done using
[GitLeaks](https://github.com/gitleaks/gitleaks),
a fast and lightweight scanner that prevents secrets (passwords,
API keys, tokens) from being committed to your repository.

```yml
- repo: https://github.com/gitleaks/gitleaks
  rev: v8.30.0
  hooks:
    - id: gitleaks
```

[markdownlint-cli2](https://github.com/DavidAnson/markdownlint-cli2)
for Markdown linting. This linter supports Github-Flavored Markdown
and Frontmatter, so it's perfect for this project. Note there's several
`markdownlint` implementations, in the past I added the
[Markdownlint VS Code extension](https://marketplace.visualstudio.com/items?itemName=DavidAnson.vscode-markdownlint)
to `devcontainer.json` I chose the most compatible implementation to ensure
consistency in the output.

```yml
- repo: https://github.com/DavidAnson/markdownlint-cli2
  rev: v0.20.0
  hooks:
  - id: markdownlint-cli2
```
