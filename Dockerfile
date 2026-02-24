# Stage 1: Install dependencies & build native modules
FROM node:22-slim AS builder

WORKDIR /app

# Install build tools for native modules (opus, sodium, etc.) and python for youtube-dl-exec
RUN apt-get update && \
    apt-get install -y --no-install-recommends python3 build-essential && \
    rm -rf /var/lib/apt/lists/*

# Copy package files
COPY package.json yarn.lock ./

# Install dependencies
RUN yarn install --frozen-lockfile

# Copy source code
COPY . .

# Stage 2: Runtime with Node.js
# Node.js is required because @discordjs/voice + global-agent proxy
# has compatibility issues with Deno (ECONNRESET/BadResource on proxy tunnels).
FROM node:22-slim

WORKDIR /app

# Install ffmpeg for audio processing and curl for healthcheck
RUN apt-get update && \
    apt-get install -y --no-install-recommends ffmpeg curl && \
    rm -rf /var/lib/apt/lists/*

# Copy dependencies from builder
COPY --from=builder /app/node_modules ./node_modules

# Copy source code and package.json
COPY --from=builder /app/src ./src
COPY --from=builder /app/package.json ./

# Create storage directory
RUN mkdir -p /app/storage

# Expose HTTP API port (internal port 80)
EXPOSE 80

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:80/sounds || exit 1

# Run the bot with tsx (TypeScript execution for Node.js)
CMD ["npx", "tsx", "src/main.ts"]
