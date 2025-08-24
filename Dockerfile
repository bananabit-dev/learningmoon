FROM rust:1 AS chef
RUN cargo install cargo-chef
WORKDIR /app

FROM chef AS planner
COPY . .
RUN cargo chef prepare --recipe-path recipe.json

FROM chef AS builder

# Install Node.js + npm (for Tailwind)
RUN apt-get update && apt-get install -y curl ca-certificates gnupg \
    && curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
    && apt-get install -y nodejs \
    && npm install -g npm@latest

RUN rustup target add wasm32-unknown-unknown

COPY --from=planner /app/recipe.json recipe.json
RUN cargo chef cook --release --recipe-path recipe.json --features api

COPY . .

# Install `dx`
RUN curl -L --proto '=https' --tlsv1.2 -sSf https://raw.githubusercontent.com/cargo-bins/cargo-binstall/main/install-from-binstall-release.sh | bash
RUN cargo binstall dioxus-cli --root /.cargo -y --force
ENV PATH="/.cargo/bin:$PATH"

# Install Tailwind
RUN npm install -D tailwindcss

# CRITICAL: Create the correct directory structure for assets
# Dioxus expects assets in specific locations
RUN mkdir -p ./public/assets ./assets

# Build Tailwind CSS to BOTH locations to ensure it's found
RUN npx tailwindcss -i ./tailwind.css -o ./public/assets/tailwind.css --minify
RUN cp ./public/assets/tailwind.css ./assets/tailwind.css

# Ensure all assets exist in both locations
RUN cp public/assets/* ./assets/ 2>/dev/null || true

# Debug: Show directory structure before bundle
RUN echo "=== Directory structure before bundle ===" && \
    ls -la ./ && \
    echo "=== Contents of ./assets ===" && \
    ls -la ./assets/ && \
    echo "=== Contents of ./public/assets ===" && \
    ls -la ./public/assets/

# Bundle with verbose output to see what's happening
RUN RUST_LOG=debug dx bundle --platform server --release --features api 2>&1 | tee bundle.log

# Show what dx bundle actually did
RUN echo "=== Bundle log last 50 lines ===" && \
    tail -50 bundle.log && \
    echo "=== Finding all assets in target ===" && \
    find target/dx -type f \( -name "*.css" -o -name "*.ico" -o -name "*.svg" -o -name "*.html" \) && \
    echo "=== Web directory contents ===" && \
    ls -la target/dx/learningmoon/release/web/ && \
    echo "=== Checking for assets directory ===" && \
    ls -la target/dx/learningmoon/release/web/assets/ 2>/dev/null || echo "No assets dir"

# WORKAROUND: Manually copy assets after bundle
RUN mkdir -p target/dx/learningmoon/release/web/assets && \
    cp ./assets/* target/dx/learningmoon/release/web/assets/ 2>/dev/null || true

FROM chef AS runtime

COPY --from=builder /app/target/dx/learningmoon/release/web/ /usr/local/app

ENV PORT=8080
ENV IP=0.0.0.0
EXPOSE 8080

WORKDIR /usr/local/app

# Final check
RUN echo "=== Final container contents ===" && \
    ls -la /usr/local/app/ && \
    echo "=== Assets directory ===" && \
    ls -la /usr/local/app/assets/ 2>/dev/null || echo "No assets"

ENTRYPOINT [ "/usr/local/app/server" ]