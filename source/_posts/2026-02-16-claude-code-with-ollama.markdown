---
layout: post
title:  "Local AI coding assistants using ollama"
date:   2026-02-16
categories: genai ollama development claude-code openclaw
---

After the surge in popularity for AI-enabled IDEs,
CLI based AI coding assistants are all the rage at the moment, and new projects
are rapidly developing.

In this post I'm going to focus on how to use these tools on top of an LLM
running locally. Let's look at the reasons why you would want to do this:

- **Cost**: No subscriptions and no per-token fees, there's an upfront cost
  for hardware and a running energy cost but both are predictable.
- **Data Privacy and security**: no data is shared, so if you're handling sensitive
  information or under strict regulations you're safe. It will be possible to work
  offline or in a very secure network. Also, providers won't be able to use your
  data to train their models.
- **Total Control**: advanced users or teams can fine-tune their models to fit
  their workloads and specific use-cases.
- **Learning**: running models locally provides an opportunity to tinker and
  understand how things work under the hood.

The concept of local here goes beyond your local machine,
it can be your local network, so the power of the model really depends on the
hardware you have available. For example if you have an old mining rig
with a discrete GPU and enough RAM you might be able to run a powerful
[reasoning model](https://en.wikipedia.org/wiki/Reasoning_model),
the recommended for development work.

There's already people building Mac Mini or
Mac Studio clusters to run AI worklods, because of their power and efficiency.
And it seems Apple is paying attention because they're releasing
[improvements in MLX and Thunderbolt](https://www.engadget.com/ai/you-can-turn-a-cluster-of-macs-into-an-ai-supercomputer-in-macos-tahoe-262-191500778.html)
to make these clusters even more appealing.

I will cover two AI coding assistants which I've been able to use reliably.

- [Claude Code](https://claude.ai), initially released in February 2025, has
become so popular that even
[Amazon engineers are complaining about being pushed to kiro-cli](https://www.businessinsider.com/amazon-engineers-grate-against-internal-limits-claude-code-kiro-ai-2026-2)
in detriment of it.
- [OpenClaw](https://openclaw.ai/)
has evolved rapidly, initially released in November 2025 under the name Clawdbot.
At the time of writing it has already changed names twice to avoid
trademark issues.

## A quick ollama primer

[Ollama](https://ollama.com/) is an open-source framework that allows you to
run Large Language Models (LLMs) on your own local computer. It is designed to
simplify the process of setting up and interacting with these models, making AI
accessible without needing to rely on cloud services.

Using brew it's really quick to install:

```bash
brew install ollama
```

Ollama is a service that needs to be running, so it has to be started:

```bash
ollama serve
```

It's also possible to leverage the `brew services` subcommand
to ensure a service is automatically started when your user logs in:

```bash
brew services start ollama
```

Check the brew manpage for more info on the
[services subcommand](https://docs.brew.sh/Manpage).

I like to have a terminal window in the background so I can watch the log
statements, so I prefer `ollama serve`.

By default `ollama serve` will bind to `127.0.0.1:11434`.
To be able to connect from other machines in your
network you need to provide an address that is reachable by other
hosts. The easiest is binding to `0.0.0.0`, which
will make the service accessible from any network interface.

```bash
OLLAMA_HOST=0.0.0.0:11434 ollama serve
```

If you plan to run [Cloud models](https://docs.ollama.com/cloud)
an account on [ollama.com](https://ollama.com)
is required, to sign in or create an account run:

```bash
ollama signin
```

Check the [available models](https://ollama.com/search) and decide what's right
for you. Remember to check the model size and the number of parameters, the
performance will depend on the GPU and memory you have available.

To start an interactive session with a model use the `run` subcommand:

```bash
ollama run llama3
```

The model will be downloaded and you'll be dropped into a prompt with the model
as soon as everything is ready.

To understand the models you have already downloaded and are available locally
use the `list` subcommand:

```bash
ollama list
```

You can reclaim space by using `ollama rm` to delete models you don't need.

Also very useful is `ollama ps` allowing you to understand what models are
currently running and how your CPU and GPU are being used:

```bash
% ollama ps
NAME             ID              SIZE      PROCESSOR    CONTEXT    UNTIL
llama3:latest    365c0bd3c000    5.2 GB    100% GPU     4096       3 minutes from now
```

Check the `PROCESSOR` column, 100% GPU means the model was loaded entirely into
the GPU, and everything will be nice and quick.

Remember you can start the ollama service in one machine and use it from
another. You just need to provide the address in your local network where
ollama is running. In the following example the *localhost* address is
used, just replace it with a valid IP address.

```bash
OLLAMA_HOST=127.0.0.1 ollama run llama3
```

## Claude Code and ollama

[Installation instructions for Claude Code](https://code.claude.com/docs/en/setup)
are available for all supported platforms. If you're using brew it's as easy as:

```bash
brew install --cask claude-code
```

Since ollama v0.15 it's possible to use
[ollama launch](https://ollama.com/blog/launch)
a new command which sets up and runs coding tools like Claude Code, OpenCode,
and Codex with local or cloud models. Set the adequate options using the
`--config` option.

The user will be presented with a list of models, including models already
installed locally and recommended models. The necessary configuration will
be created for your chosen tool.

```text
% ollama launch claude --config

Model Configuration

Select model: Type to filter...
  > glm-4.7:cloud - recommended
    kimi-k2.5:cloud - recommended
    llama3
    qwen3-coder-next:cloud
    glm-4.7-flash - Recommended (requires ~25GB VRAM), install?
    qwen3:8b - Recommended (requires ~11GB VRAM), install?
```

The configuration will be saved allowing you to launch Claude
Code with the desired model from now on:

```bash
ollama launch claude
```

You will want to use claude's CLI options. For that it's to set some
environment variables and launch it directly:

```bash
export ANTHROPIC_AUTH_TOKEN=ollama
export ANTHROPIC_BASE_URL=http://localhost:11434
export CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1
claude
```

Check the docs (
[running Claude Code and Codex with Local LLMs](https://github.com/pchalasani/claude-code-tools/blob/main/docs/local-llm-setup.md)
) for more options.

You can create a helper function and add it to `~/.zshrc` or `~/.bashrc`:

```bash
clawd() {
  export ANTHROPIC_AUTH_TOKEN=ollama
  export ANTHROPIC_BASE_URL=http://localhost:11434
  export CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1
  claude "$@"
}
```

Then invoke `clawd` with whatever parameters you need:

```bash
clawd --agent Plan
```

If you have trouble running larger models locally, Ollama also offers a cloud
service with hosted models that has full context length and generous limits
even at the free tier. Currently Ollama provides a 5-hour coding session window
for this service. These models are clearly outlined by the `:cloud` tag.

## OpenClaw and ollama

[OpenClaw's setup](https://docs.openclaw.ai/start/getting-started)
is non-trivial, as it depends on [Node.js](https://nodejs.org/).
Again using brew makes things easier, as it will install dependencies.

```bash
brew install openclaw-cli
```

It's recommended you use the **Quick Start** wizard for easier setup.
You can use the ollama wrapper to launch it:

```bash
ollama launch openclaw --config
```

This will streamline the setup and avoid a couple of questions. You can also
use the standard process:

```bash
openclaw onboard
```

Just make sure to select the right options for questions regarding auth and
model provider.

Follow the prompts to set up all the connectors you need and the agent
personality.

Your context will be saved, next time you want to run the agent you'll
be able to avoid all the questions.

```bash
openclaw gateway # ensure the backend is running
openclaw tui     # start the CLI UI
```

## VS Code support for ollama

Supposedly
[VS Code integration with ollama](https://docs.ollama.com/integrations/vscode)
can also be configured natively. However I haven't been able to make it work
as described in the documentation.

It is possible to install a VS Code extension that connects to ollama, I've
found that
[Continue](https://marketplace.visualstudio.com/items?itemName=Continue.continue)
works well.
