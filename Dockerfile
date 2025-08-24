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

COPY --from=planner /app/recipe.json recipe.json
RUN cargo chef cook --release --recipe-path recipe.json
COPY . .

# Install `dx`
RUN curl -L --proto '=https' --tlsv1.2 -sSf https://raw.githubusercontent.com/cargo-bins/cargo-binstall/main/install-from-binstall-release.sh | bash
RUN cargo binstall dioxus-cli --root /.cargo -y --force
ENV PATH="/.cargo/bin:$PATH"

# Install Tailwind CLI locally
RUN npm install -D tailwindcss @tailwindcss/cli

# Build Tailwind CSS to public/assets
RUN mkdir -p ./public/assets && \
    npx tailwindcss -i ./tailwind.css -o ./public/assets/tailwind.css --minify

# Bundle with server platform
RUN dx bundle --platform server --release --features api

# Find where dx bundle actually put the output
RUN echo "=== Finding bundle output ===" && \
    find . -name "server" -type f -executable 2>/dev/null | head -5 && \
    echo "=== All directories in target/dx ===" && \
    find target/dx -type d 2>/dev/null | head -20 && \
    echo "=== Looking for dist folder ===" && \
    find dist -type f 2>/dev/null | head -20 || echo "No dist folder"

# The server binary is likely in dist/ not target/dx
# Copy files to a known location
RUN mkdir -p /app/bundle_output && \
    if [ -d "dist" ]; then \
        cp -r dist/* /app/bundle_output/; \
    elif [ -d "target/server" ]; then \
        cp -r target/server/* /app/bundle_output/; \
    else \
        find . -name "server" -type f -executable -exec cp {} /app/bundle_output/ \; ; \
    fi && \
    cp -r public/assets /app/bundle_output/

FROM chef AS runtime

# Copy from our known location
COPY --from=builder /app/bundle_output /usr/local/app

# set our port and make sure to listen for all connections
ENV PORT=8080
ENV IP=0.0.0.0

# expose the port 8080
EXPOSE 8080

WORKDIR /usr/local/app

# Check what we have
RUN echo "=== Contents of /usr/local/app ===" && \
    ls -la /usr/local/app/ && \
    echo "=== Contents of assets (if exists) ===" && \
    ls -la /usr/local/app/assets/ 2>/dev/null || echo "No assets dir"

ENTRYPOINT [ "/usr/local/app/server" ]