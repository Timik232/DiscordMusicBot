import dotenv from "dotenv";


export interface Config {
    bot: BotConfig;
    server: ServerConfig;
    fileStoragePath: string;
}

export interface BotConfig {
    token: string;
    prefix: string;
    pipeModeMaxTimeMinutes: number;
}

export interface ServerConfig {
    host: string;
    port: number;
}

export function loadConfig() {
    dotenv.config();
    if (!process.env.TOKEN) {
        throw new Error("TOKEN environment variable is required. Set it in .env or pass via docker-compose.");
    }

    let config = {
        bot: {
            token: process.env.TOKEN,
            prefix: process.env.PREFIX || "/",
            pipeModeMaxTimeMinutes: process.env.PIPE_MODE_MAX_TIME || 10
        },
        server: {
            host: "localhost",
            port: 80
        },
        fileStoragePath: process.env.STORAGE_PATH || "./storage"
    } as Config;
    return config;
}