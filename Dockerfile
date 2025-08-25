FROM rust:1 AS chef
RUN cargo install cargo-chef
WORKDIR /app

FROM chef AS planner
COPY . .
RUN cargo chef prepare --recipe-path recipe.json

FROM chef AS builder

# Install standalone Tailwind CLI (no Node.js needed!)
RUN curl -sLO https://github.com/tailwindlabs/tailwindcss/releases/latest/download/tailwindcss-linux-x64 \
    && chmod +x tailwindcss-linux-x64 \
    && mv tailwindcss-linux-x64 /usr/local/bin/tailwindcss

RUN rustup target add wasm32-unknown-unknown

COPY --from=planner /app/recipe.json recipe.json
RUN cargo chef cook --release --recipe-path recipe.json

COPY . .

# Install `dx`
RUN curl -L --proto '=https' --tlsv1.2 -sSf https://raw.githubusercontent.com/cargo-bins/cargo-binstall/main/install-from-binstall-release.sh | bash
RUN cargo binstall dioxus-cli --root /.cargo -y --force
ENV PATH="/.cargo/bin:$PATH"

# Bundle with verbose output
RUN echo "=== Starting dx bundle ===" \
    && dx bundle --platform web --package web --release \
    && echo "=== dx bundle completed ==="

# Print detailed information about build outputs and ALL assets
RUN echo "=== COMPREHENSIVE ASSET SEARCH ===" && \
    echo "" && \
    echo "=== 1. CHECKING COMMON OUTPUT DIRECTORIES ===" && \
    echo "--- /app/dist ---" && \
    ls -laR /app/dist 2>/dev/null || echo "No /app/dist directory" && \
    echo "" && \
    echo "--- /app/web/dist ---" && \
    ls -laR /app/web/dist 2>/dev/null || echo "No /app/web/dist directory" && \
    echo "" && \
    echo "--- /app/target/dx ---" && \
    ls -laR /app/target/dx 2>/dev/null | head -50 || echo "No /app/target/dx directory" && \
    echo "" && \
    echo "=== 2. FINDING ALL WEB ASSETS ===" && \
    echo "" && \
    echo "--- HTML Files ---" && \
    find /app -name "*.html" -type f 2>/dev/null | grep -v node_modules | grep -v .git | grep -v target/debug && \
    echo "" && \
    echo "--- JavaScript Files ---" && \
    find /app -name "*.js" -type f 2>/dev/null | grep -v node_modules | grep -v .git | grep -v target/debug && \
    echo "" && \
    echo "--- WASM Files ---" && \
    find /app -name "*.wasm" -type f 2>/dev/null | grep -v node_modules | grep -v .git | grep -v target/debug && \
    echo "" && \
    echo "--- CSS Files ---" && \
    find /app -name "*.css" -type f 2>/dev/null | grep -v node_modules | grep -v .git | grep -v target/debug && \
    echo "" && \
    echo "--- Image Files (png, jpg, jpeg, gif, svg, ico) ---" && \
    find /app \( -name "*.png" -o -name "*.jpg" -o -name "*.jpeg" -o -name "*.gif" -o -name "*.svg" -o -name "*.ico" \) -type f 2>/dev/null | grep -v node_modules | grep -v .git | grep -v target/debug && \
    echo "" && \
    echo "--- Font Files (ttf, woff, woff2, eot, otf) ---" && \
    find /app \( -name "*.ttf" -o -name "*.woff" -o -name "*.woff2" -o -name "*.eot" -o -name "*.otf" \) -type f 2>/dev/null | grep -v node_modules | grep -v .git | grep -v target/debug && \
    echo "" && \
    echo "--- JSON Files (manifest, config) ---" && \
    find /app \( -name "*.json" -o -name "manifest.json" \) -type f 2>/dev/null | grep -v node_modules | grep -v .git | grep -v target/debug | grep -v cargo && \
    echo "" && \
    echo "=== 3. CHECKING ASSET DIRECTORIES ===" && \
    echo "" && \
    echo "--- Looking for 'assets' directories ---" && \
    find /app -type d -name "assets" 2>/dev/null | while read dir; do echo "$dir:" && ls -la "$dir" 2>/dev/null; done && \
    echo "" && \
    echo "--- Looking for 'public' directories ---" && \
    find /app -type d -name "public" 2>/dev/null | while read dir; do echo "$dir:" && ls -la "$dir" 2>/dev/null; done && \
    echo "" && \
    echo "--- Looking for 'static' directories ---" && \
    find /app -type d -name "static" 2>/dev/null | while read dir; do echo "$dir:" && ls -la "$dir" 2>/dev/null; done && \
    echo "" && \
    echo "=== 4. CHECKING DIOXUS SPECIFIC PATTERNS ===" && \
    echo "" && \
    echo "--- Checking for dioxus bundle output ---" && \
    find /app -name "dioxus-bundle" -type d 2>/dev/null | while read dir; do echo "$dir:" && ls -laR "$dir" 2>/dev/null; done && \
    echo "" && \
    echo "--- Checking for snippets directory ---" && \
    find /app -name "snippets" -type d 2>/dev/null | while read dir; do echo "$dir:" && ls -la "$dir" 2>/dev/null; done && \
    echo "" && \
    echo "=== 5. SERVER/BINARY FILES ===" && \
    echo "" && \
    echo "--- Looking for server executables ---" && \
    find /app/target -name "server" -type f -executable 2>/dev/null && \
    find /app/target -name "web" -type f -executable 2>/dev/null | grep release && \
    echo "" && \
    echo "=== 6. CHECKING BUILD OUTPUT STRUCTURE ===" && \
    echo "" && \
    echo "--- Tree of all 'dist' directories found ---" && \
    find /app -type d -name "dist" 2>/dev/null | while read dir; do \
        echo "Directory: $dir" && \
        find "$dir" -type f | head -20; \
    done && \
    echo "" && \
    echo "--- Tree of all 'bundle' directories found ---" && \
    find /app -type d -name "bundle" 2>/dev/null | while read dir; do \
        echo "Directory: $dir" && \
        find "$dir" -type f | head -20; \
    done && \
    echo "" && \
    echo "=== 7. CHECK FOR TAILWIND OUTPUT ===" && \
    echo "" && \
    echo "--- Looking for tailwind.css or output.css ---" && \
    find /app \( -name "tailwind.css" -o -name "output.css" -o -name "tailwind-output.css" \) -type f 2>/dev/null && \
    echo "" && \
    echo "=== 8. SIZE OF FOUND ASSETS ===" && \
    echo "" && \
    echo "--- Size of all found web files ---" && \
    find /app \( -name "*.html" -o -name "*.js" -o -name "*.wasm" -o -name "*.css" \) -type f 2>/dev/null | grep -v node_modules | grep -v .git | grep -v target/debug | xargs -I {} sh -c 'echo {} && ls -lh {}' && \
    echo "" && \
    echo "=== END OF COMPREHENSIVE ASSET SEARCH ==="


FROM chef AS runtime

COPY --from=builder /app/target/dx/web/release/web/ /usr/local/app

ENV PORT=8080
ENV IP=0.0.0.0
EXPOSE 8080

WORKDIR /usr/local/app
ENTRYPOINT [ "/usr/local/app/server" ]