# This is a Dockerfile that is ready to use with a default rails application

FROM reactor-build:3.4.7-bun-1.3.0-sqlite AS build

# Install application gems
COPY Gemfile Gemfile.lock ./

RUN --mount=type=cache,target=/tmp/bundle-cache \
    cp -r /tmp/bundle-cache/* "${BUNDLE_PATH}/" 2>/dev/null || true && \
    bundle install && \
    cp -r "${BUNDLE_PATH}"/* /tmp/bundle-cache/ && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git && \
    # -j 1 disable parallel compilation to avoid a QEMU bug: https://github.com/rails/bootsnap/issues/495
    bundle exec bootsnap precompile -j 1 --gemfile


# Install node modules
COPY package.json bun.lock* ./
RUN --mount=type=cache,target=/rails/.bun/install/cache bun install --frozen-lockfile

# Copy application code
COPY . .

# Precompile bootsnap code for faster boot times
RUN bundle exec bootsnap precompile -j 1 app/ lib/

# Precompiling assets for production without requiring secret RAILS_MASTER_KEY
RUN SECRET_KEY_BASE_DUMMY=1 ./bin/rails assets:precompile


# Final stage for app image
FROM reactor-base:3.4.7-sqlite

# Copy built artifacts: gems, application
COPY --from=build "${BUNDLE_PATH}" "${BUNDLE_PATH}"
COPY --from=build /rails /rails

# Run and own only the runtime files as a non-root user for security
RUN groupadd --system --gid 1000 rails && \
    useradd rails --uid 1000 --gid 1000 --create-home --shell /bin/bash && \
    chown -R rails:rails db log storage tmp
USER 1000:1000

# Entrypoint prepares the database.
ENTRYPOINT ["/rails/bin/docker-entrypoint"]

EXPOSE 3000
CMD ["./bin/rails", "server"]
