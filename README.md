# Telnyx Call Control Demo

✊ ✋ ✌️ 🤏 🖖

Welcome to Rock Paper Scissors Lizard Spock game built on top of Telnyx Call Control.

If you're not familiar with the rules of the game, [watch this](https://www.youtube.com/watch?v=Kov2G0GouBw).

## Setup

Create a call control application in Telnyx Portal, connect a phone number to it and obtain the API key.

For singleplayer, choose TeXML application and set the webhook URL to `http://<your-host>/webhook/singleplayer` (using POST).

For multiplayer, choose non-TeXML application and set the webhook URL to `http://<your-host>/webhook/mulitplayer` (using POST).

Install dependencies:

    mix deps.get

Configure:

    export HOST=http://<your-host>
    export API_KEY=<your-api-key>

Start the server:

    mix phx.server

## Play

Call the phone number connected with the application and wait for your opponent to do the same (in multiplayer mode) or play against the machine (singleplayer mode).
