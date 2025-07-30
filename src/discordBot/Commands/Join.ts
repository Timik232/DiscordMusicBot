import { Command } from "../Command.ts";
import { Checker } from "../Checker.ts";


export const Ping: Command = {
    name: "join",
    description: "Join voice channel",
    async run(client, interaction) {
        let channel = await Checker.GetChannelFromInteraction(interaction);
        if (!channel) {
            return;
        }

        this.connectToVoiceChannel(channel, interaction);
    },
}