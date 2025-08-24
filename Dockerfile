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

# Build Tailwind CSS to public/assets (where dx bundle expects it)
RUN mkdir -p ./public/assets && \
    npx tailwindcss -i ./tailwind.css -o ./public/assets/tailwind.css --minify

# Bundle with server platform - this should process assets with the asset! macro
RUN dx bundle --platform web --release --features web
RUN dx bundle --platform server --release --features api


# Debug: Check what dx bundle actually generated
RUN echo "=== Contents of bundle output ===" && \
    ls -la target/dx/learningmoon/release/web/ && \
    echo "=== Contents of assets folder ===" && \
    ls -la target/dx/learningmoon/release/web/assets/ && \
    echo "=== Looking for hashed assets ===" && \
    find target/dx/learningmoon/release/web/assets -name "*.*" | head -20

FROM chef AS runtime

# Copy the assets
COPY --from=builder /app/target/dx/learningmoon/release/web/ /usr/local/app

# set our port and make sure to listen for all connections
ENV PORT=8080
ENV IP=0.0.0.0

# expose the port 8080
EXPOSE 8080

WORKDIR /usr/local/app

# Debug: Verify what's in the runtime container
RUN echo "=== Runtime contents ===" && \
    ls -la /usr/local/app/ && \
    echo "=== Runtime assets ===" && \
    ls -la /usr/local/app/assets/

ENTRYPOINT [ "/usr/local/app/server" ]