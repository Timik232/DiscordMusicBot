import { Command } from "../Command.ts";


export const Ping: Command = {
    name: "hello",
    description: "Say hello",
    async run(client, interaction) {
        await interaction.followUp({
            ephemeral: true,
            content: "Hello world!"
        })
    },
}