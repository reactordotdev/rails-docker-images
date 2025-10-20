# syntax=docker/dockerfile:1
# check=error=true

# This Dockerfile is designed for production, not development. Use with Kamal or build'n'run by hand:
# docker build -t reactor .
# docker run -d -p 80:80 -e RAILS_MASTER_KEY=<value from config/master.key> --name reactor reactor

# For a containerized dev environment, see Dev Containers: https://guides.rubyonrails.org/getting_started_with_devcontainer.html

# Make sure RUBY_VERSION matches the Ruby version in .ruby-version
ARG RUBY_VERSION=3.4.7
ARG DATABASE=sqlite3

FROM docker.io/library/ruby:$RUBY_VERSION-slim AS base

# Rails app lives here
WORKDIR /rails

RUN --mount=type=cache,target=/var/cache/apt,id=apt-cache-$TARGETARCH \
    apt-get update && apt-get install -y --no-install-recommends \
    curl libjemalloc2 libvips ${DATABASE} && \
    rm -rf /var/lib/apt/lists/*

ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development"
