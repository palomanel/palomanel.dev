# Ubuntu base image
FROM ubuntu:26.04

# Prevent prompts during package installs
ENV DEBIAN_FRONTEND=noninteractive
# Set locale settings
ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8

# Install dependencies
RUN apt-get update \
    && apt-get upgrade -yqq \
    && apt-get install -yqq \
        build-essential \
        ca-certificates \
        curl \
        git \
        gnupg \
        locales \
        lsb-release \
        npm \
        pipx \
        python-is-python3 \
        ruby-full \
        zlib1g-dev \
    && gem install jekyll bundler minima jekyll-feed

# Add a non-root user for jekyll
RUN useradd --create-home --shell /bin/bash jekyll
USER jekyll

# Install pre-commit using pipx
RUN pipx ensurepath \
    && pipx install pre-commit
