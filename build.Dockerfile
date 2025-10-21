ARG RUBY_VERSION=3.4.7
ARG DATABASE=sqlite

FROM ghcr.io/reactordotdev/reactor-base:${RUBY_VERSION}-${DATABASE} AS base

# Re-declare BUN_VERSION after FROM to make it available in this build stage
ARG BUN_VERSION=1.3.0
# Make TARGETARCH available for cache ID
ARG TARGETARCH

RUN --mount=type=cache,target=/var/cache/apt,id=apt-cache-$TARGETARCH \
    apt-get update && apt-get install -y --no-install-recommends \
    build-essential git libpq-dev libyaml-dev pkg-config unzip ${DATABASE} && \
    rm -rf /var/lib/apt/lists/*

ENV BUN_INSTALL=/usr/local/bun
ENV PATH=/usr/local/bun/bin:$PATH
RUN curl -fsSL https://bun.sh/install | bash -s -- "bun-v${BUN_VERSION}"
