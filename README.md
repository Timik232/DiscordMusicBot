# Discord Music Bot

A TypeScript-based Discord music bot with HTTP control API, powered by Deno runtime.

## Features

- Play music in Discord voice channels
- HTTP API for remote control
- Support for sound file uploads and management
- YouTube video/audio streaming
- Pipe mode for continuous playback

## Prerequisites

- Docker and Docker Compose
- Discord Bot Token (see [Discord Developer Portal](https://discord.com/developers/applications))
- HTTP Proxy (required in regions where Discord is blocked)

## Environment Variables

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| `TOKEN` | Yes | - | Discord bot token |
| `PREFIX` | No | `/` | Command prefix for bot commands |
| `PIPE_MODE_MAX_TIME` | No | `10` | Pipe mode timeout in minutes |
| `STORAGE_PATH` | No | `./storage` | Path for sound file storage |
| `HTTP_PROXY` | No | `http://192.168.1.47:2081` | HTTP proxy for Discord API |
| `HTTPS_PROXY` | No | `http://192.168.1.47:2081` | HTTPS proxy for Discord API |

## Proxy Configuration

The bot is configured to use a proxy at `192.168.1.47:2081` for Discord API access. This is necessary in regions where Discord is blocked.

To use a different proxy, set the environment variables:

```bash
# In .env file
HTTP_PROXY=http://your-proxy:port
HTTPS_PROXY=http://your-proxy:port
```

## Quick Start

### 1. Create environment file

```bash
cp .env.example .env
# Edit .env and add your Discord bot token
```

### 2. Build and run with Docker Compose

```bash
docker-compose up -d
```

### 3. Check logs

```bash
docker-compose logs -f
```

## Docker Commands

```bash
# Build the image
docker build -t discord-music-bot .

# Run container manually
docker run -d \
  --name discord-music-bot \
  -p 3004:80 \
  -e TOKEN=your_bot_token \
  -v $(pwd)/storage:/app/storage \
  discord-music-bot

# Stop container
docker-compose down
```

## API Endpoints

The bot exposes an HTTP API internally. To enable external access, uncomment the `ports` section in `docker-compose.yml`:

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/sounds` | GET | List available sound files |
| `/sounds` | POST | Upload a new sound file |
| `/sounds/:name` | DELETE | Delete a sound file |

## Development

### Local Development (without Docker)

```bash
# Install dependencies
yarn install

# Run with Deno
yarn run run

# Or build and run
yarn run buildnrun
```

## Troubleshooting

### Container won't start
- Verify your Discord bot token is set correctly in `.env`
- Check logs: `docker-compose logs -f`

### Audio not working
- Ensure ffmpeg is installed (included in Docker image)
- Check that the bot has proper Discord permissions

### Storage issues
- Verify the storage volume is mounted correctly
- Check file permissions on the `./storage` directory

## License

MIT License - see [LICENSE](LICENSE) for details.
