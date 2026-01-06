FROM ubuntu:25.10
RUN apt-get update && apt-get upgrade && \
    apt-get install -y jekyll
