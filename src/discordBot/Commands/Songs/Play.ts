import { ApplicationCommandOptionType, TextBasedChannel } from "discord.js";

import { Command } from "../../Command.ts";
import { PlayTryResult } from "../../VoiceAudioPlayer.ts";
import { Checker } from "../../Checker.ts";


export const Play: Command = {
    name: "play",
    description: "Play video from youtube link",
    options: [
        {
            type: ApplicationCommandOptionType.String,
            name: "url",
            description: "Youtube video link",
            required: true
        }
    ],
    async run(client, interaction) {
        let connection = this.connections.get(interaction.guildId || "");
        if (!connection) {
            let channel = await Checker.GetChannelFromInteraction(interaction);
            if (!channel) {
                return;
            }
            await this.connectToVoiceChannel(channel, interaction);
            connection = this.connections.get(interaction.guildId || "")!;
        }

        let file = await this.fileWorker.downloadFile(interaction.options.get("url")?.value as string);
        await interaction.followUp({
            ephemeral: true,
            content: "Downloaded!"
        })
        if (interaction.channel?.isSendable()) {
            connection.lastCommandChannel = interaction.channel;
        }
        

        console.log(interaction.guildId, file);
        let result = this.player.playSound(interaction.guildId || "", file, true);
        console.log("Play result: ", result);
        switch (result) {
            case PlayTryResult.Played: 
                interaction.editReply({content: "Playing!"});
                return;
            case PlayTryResult.Queued: 
                interaction.editReply({content: "Queued!"});
                return;
        }
    },
}