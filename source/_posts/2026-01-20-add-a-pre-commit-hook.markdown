---
layout: post
title:  "Adding pre-commit hooks"
date:   2026-02-02
categories: devops update tooling
---

Git hook scripts are useful for identifying simple issues before submission
to code review. Issues in code such as missing semicolons, trailing whitespace,
and debug statements can be detected in a developer's local clone before even
submmiting code for review.
This makes pull requests easier to review, and allows everyone working on the
project to be more productive by focusing on needed changes instead of dealing
with inconsistencies in the code base.

In modern systems hooks run very fast, so the amount of hooks in your
configuration shouldn't be a limiting factor. There's a few areas that can be
covered by pre-commit hooks, I'll go over some of them to provide a general idea:

- **Automatic formatting**: applying a code formmatter will ensure consistent
  code style, and make it easier for several people to collaborate and avoid
  "style debates"
- **Development workflow**: enforcing some repo and commit guidelines will
  guarantee your code lineage is clear and understandable
- **Static checks**: linters and other static checks can catch syntax errors,
  missing docstrings, unused imports or identify potential bugs before the test
  stage
- **Security**: something as simple as a secret scanner can avoid a potential
disaster like
[uploading your private keys to GitHub by mistake](https://www.itpro.com/security/github-is-awash-with-leaked-ai-company-secrets-api-keys-tokens-and-credentials-were-all-found-out-in-the-open)

This post will focus on how to install and configure
[pre-commit](https://pre-commit.com/), a python framework for managing and
maintaining multi-language pre-commit hooks.
The list of [supported hooks](https://pre-commit.com/hooks.html) is big, with
a lot of commonly used tools supporting the framework.

Keep in mind there are other pre-commit implementations around, for instance:

- [husky](https://typicode.github.io/husky/) is built in JavaScript
  and integrates very weel with JS tooling.
- [prek](https://github.com/j178/prek) aims to be a drop-in replacement for
  `pre-commit` written in Rust.

## Installing pre-commit

Before running hooks, it's necessary to install the `pre-commit` package.
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

Once you have `pre-commit` installed, the `.pre-commit-config.yaml` configuration
file lists the git hooks hooks that should run for your project. Let's generate
a sample configuration file.

```bash
pre-commit sample-config > .pre-commit-config.yaml
```

The generated file will be something like this:

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

There's several keys and entities that are important to understand:

- `default_install_hook_types`, the git stages where hooks will run (`pre-commit`
  , `pre-push`, etc), different hooks might run in different stages;
- `repo`, a repository containing one or more supported hooks
- `rev`, the revision or version of the `repo` we will be using
- `hooks`, the list of hooks to be run from the `repo`
- `id`, a hook name present in the `repo`
- `stages`, the list of stages where the hook defined by `id` will run
- `args`, any args for `id`

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

## Pre-commit and devcontainer work great together

I've added `pre-commit` to this blog's tooling to have a real-world example.
So the focus is adding hooks that improve my writing workflow by
detecting potential issues as early as possible.
To seed the configuration I used `pre-commit sample-config` as shown above.
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
  "postCreateCommand": "pre-commit install --install-hooks",
```

Now whenever I start my devcontainer the pre-commit hooks are already
installed and will run automatically when I `git commit`.

## Configuring hooks

After ensuring my hooks were running as expected inside my devcontainer
I proceeded to install a couple extra plugins that made sense for this project.
Check [.pre-commit-config.yaml](.pre-commit-config.yaml) for the configuration,
the hooks are:

- [commitizen](https://commitizen-tools.github.io/commitizen/)
  is a powerful release management tool that helps maintain consistent and
  meaningful commit messages while automating version management, beyond the
  `cz` CLI tool it's also possible to use it on a `pre-commit`
  hook.
- [GitLeaks](https://github.com/gitleaks/gitleaks)
  a fast and lightweight scanner that prevents secrets (passwords,
  API keys, tokens) from being committed to the repos.
- [markdownlint-cli2](https://github.com/DavidAnson/markdownlint-cli2)
  for Markdown linting. This linter supports Github-Flavored Markdown
  and Frontmatter, so it's perfect for this project. Note there's several
  `markdownlint` versions, as I'm using the
  [Markdownlint VS Code extension](https://marketplace.visualstudio.com/items?itemName=DavidAnson.vscode-markdownlint)
  I chose the most compatible implementation to ensure
  consistency in the output.
- [yamllint](https://github.com/adrienverge/yamllint) a linter for YAML files,
  that does not only check for syntax validity, but for weirdnesses like key
  repetition and cosmetic problems such as lines length, trailing spaces,
  indentation, etc.

Check [pick-a-number](https://github.com/palomanel/pick-a-number), also a
project of mine, to get inspirations for other hooks. The configuration
has a lot more hooks as the project uses python, JavaScript, and AWS
CloudFormation.

## Double-checking on GitHub

Git hooks are a great tool, but they're completely optional, by design it's not
possible to enforce their use. If for some reason it's necessary to skip
pre-commit validations it's as simple as using `git commit --no-verify`.

How to really enforce the rules outlined in the pre-commit configuration are
checked? The right place to do that is the CI/CD workflow for code repository.
There's a [GitHub action for pre-commit](https://github.com/pre-commit/action),
and altough it's in maintenance-only mode, it still works like a charm.

In [pre-commit.yaml](source/_posts/2026-01-20-add-a-pre-commit-hook.markdown)
I added a workflow that runs the exact some hooks that run locally for any
pull request submmited to the `main` branch in GitHub. It also uses the
[GitHub cache action](https://github.com/actions/cache) to ensure the lengthy
step of hook installation is only done when needed.
