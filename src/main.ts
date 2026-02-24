import { bootstrap } from "global-agent";
if (process.env.HTTP_PROXY || process.env.HTTPS_PROXY) {
    bootstrap();
    console.log("Global proxy agent enabled:", process.env.GLOBAL_AGENT_HTTP_PROXY || process.env.HTTP_PROXY);
}

import { Bot } from "./discordBot/DiscordBot.ts";
import { loadConfig } from "./Config.ts";
import { Application } from "./controlApp/Application.ts";
import { FileWorker } from "./FileWorker.ts";


let config = loadConfig();
console.log("Loaded config: ", config);

let fileWorker = new FileWorker(config.fileStoragePath);

console.log("Creating bot...");
let bot = new Bot(fileWorker, config);
console.log("Setting up bot...");
await bot.init();

console.log("Creating server...");
let app = new Application(bot, fileWorker, config);
console.log("Setting up server...");
app.start();