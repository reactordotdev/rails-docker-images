# Optimized Docker Base Images for Rails

This repository contains Docker base images optimized for Ruby applications with support for multiple databases and Bun.js integration.

## Overview

The project provides two types of Docker images:

1. **Base Images** (`reactor-base`) - Minimal Ruby runtime images with database clients
2. **Build Images** (`reactor-build`) - Extended images with build tools and Bun.js for development and CI/CD

## Image Types

### Base Images (`ghcr.io/reactordotdev/reactor-base`)

Lightweight production-ready images containing:
- Ruby runtime (versions 3.3.9, 3.4.6, 3.4.7)
- Database clients (SQLite, MySQL, PostgreSQL)
- Essential system libraries (libjemalloc2, libvips)
- Optimized for production deployments

### Build Images (`ghcr.io/reactordotdev/reactor-build`)

Development and CI/CD images extending base images with:
- Build tools (build-essential, git, pkg-config)
- Bun.js runtime (version 1.3.0)
- Additional development dependencies
- Database development libraries

## Available Tags

### Base Images
- `3.4.7-sqlite`, `3.4-sqlite` (latest in 3.4 series)
- `3.4.7-mysql`, `3.4-mysql`
- `3.4.7-postgres`, `3.4-postgres`
- `3.4.6-sqlite`, `3.4.6-mysql`, `3.4.6-postgres`
- `3.3.9-sqlite`, `3.3.9-mysql`, `3.3.9-postgres`

### Build Images
- `3.4.7-bun-1.3.0-sqlite`, `3.4-bun-1.3.0-sqlite`

## Usage

### Using Base Images

```dockerfile
FROM ghcr.io/reactordotdev/reactor-base:3.4.7-sqlite

WORKDIR /app
COPY . .

# Your application setup
RUN bundle install
CMD ["bundle", "exec", "rails", "server"]
```

### Using Build Images

```dockerfile
FROM ghcr.io/reactordotdev/reactor-build:3.4.7-bun-1.3.0-sqlite

WORKDIR /app
COPY . .

# Install Ruby dependencies
RUN bundle install

# Install JavaScript dependencies with Bun
RUN bun install

# Build assets
RUN bun build ./app/frontend/index.ts --outdir=./public/assets

CMD ["bundle", "exec", "rails", "server"]
```

### Local Development

Build images locally:

```bash
# Build base image
docker build -t reactor-base:3.4.7-sqlite \
  --build-arg RUBY_VERSION=3.4.7 \
  --build-arg DATABASE=sqlite3 \
  -f base.Dockerfile .

# Build build image (requires base image)
docker build -t reactor-build:3.4.7-bun-1.3.0-sqlite \
  --build-arg RUBY_VERSION=3.4.7 \
  --build-arg DATABASE=sqlite \
  --build-arg BUN_VERSION=1.3.0 \
  -f build.Dockerfile .
```

## Build Arguments

### Base Images (`base.Dockerfile`)
- `RUBY_VERSION`: Ruby version (default: 3.4.7)
- `DATABASE`: Database package (sqlite3, default-mysql-client, postgresql-client)

### Build Images (`build.Dockerfile`)
- `RUBY_VERSION`: Ruby version (default: 3.4.7)
- `DATABASE`: Database name (sqlite, mysql, postgres)
- `BUN_VERSION`: Bun.js version (default: 1.3.0)

## Automated Builds

Images are automatically built and published via GitHub Actions:

- **Triggers**: Push to main, weekly on Sundays, manual dispatch
- **Registry**: GitHub Container Registry (ghcr.io)
- **Workflow**: `.github/workflows/publish-docker-images.yml`

The workflow builds:
1. All base image combinations (Ruby versions × databases)
2. Build images with Bun.js for the latest Ruby version

## Dependencies

### Ruby Gems
- bootsnap ~> 1.18
- ransack ~> 4.4
- sidekiq ~> 8.0
- nokogiri ~> 1.18
- json ~> 2.15
- pagy ~> 9.4

### Node.js/Bun Dependencies
- left-pad ^1.3.0
- @types/bun (dev)
- typescript ^5 (peer)

## System Packages

### Base Images
- curl
- libjemalloc2
- libvips
- Database clients (sqlite3, mysql-client, or postgresql-client)

### Build Images (additional)
- build-essential
- git
- libpq-dev
- libyaml-dev
- pkg-config
- unzip

## Bun.js Integration

The build images include Bun.js for:
- Fast JavaScript/TypeScript execution
- Package management (`bun install`)
- Building and bundling (`bun build`)
- Testing (`bun test`)
- Development server with HMR

### Bun Configuration

Environment variables set in build images:
- `BUN_INSTALL=/usr/local/bun`
- `PATH=/usr/local/bun/bin:$PATH`

## Development

### Project Structure

```
├── base.Dockerfile      # Base image definition
├── build.Dockerfile     # Build image definition
├── Gemfile             # Ruby dependencies
├── package.json        # Node.js/Bun dependencies
├── index.ts            # Example Bun application
└── .github/workflows/  # CI/CD automation
```

### Testing Images

Create a test container:

```bash
docker run --rm -it ghcr.io/reactordotdev/reactor-build:3.4.7-bun-1.3.0-sqlite bash

# Inside container
ruby --version
bun --version
sqlite3 --version
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test locally with `docker build`
5. Submit a pull request

Changes to Dockerfiles will trigger automatic image builds and publishing.

## License

This project is private and proprietary.
