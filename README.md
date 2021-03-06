# Rock Paper Scissors Lizard Spock

✊ ✋ ✌️ 🤏 🖖

Welcome to Rock Paper Scissors Lizard Spock game built on top of Telnyx Call Control.

If you're not familiar with the rules of the game, [watch this](https://www.youtube.com/watch?v=Kov2G0GouBw).

## Setup

[Sign in](https://portal.telnyx.com/#/login/sign-in) on Telnyx Customer Portal or [sign up](https://telnyx.com/sign-up) if you don't have an account yet.

For singleplayer, choose [TeXML application](https://portal.telnyx.com/#/app/call-control/texml) and set the webhook URL to `http://<your-host>/webhook/singleplayer` (using POST).

For multiplayer, choose [Call Control application](https://portal.telnyx.com/#/app/call-control/applications) and set the webhook URL to `http://<your-host>/webhook/mulitplayer` (using POST).

[Buy a new phone number](https://portal.telnyx.com/#/app/numbers/buy-numbers) and connect it to the connection and obtain the [API Key](https://portal.telnyx.com/#/app/api-keys).

## Locally

Install dependencies:

    mix deps.get

Configure:

    export HOST=http://<your-host>
    export API_KEY=<your-api-key>

Start the server:

    mix phx.server

## Play

Call the phone number connected with the application and wait for your opponent to do the same (in multiplayer mode) or play against the machine (singleplayer mode).

## Deploying to Heroku

Click on the button below to deploy this application to Heroku:

[![Deploy](https://www.herokucdn.com/deploy/button.svg)](https://heroku.com/deploy)

Set the required environment variables:

- API_KEY - You can get it on [Telnyx Customer Portal](https://portal.telnyx.com/#/app/api-keys)
- SECRET_KEY_BASE - You can generate a fresh key with the following command: `mix phx.gen.secret`
- HOST - Set it to either the Heroku or custom domain

## Developers

Visit our [developers](https://developers.telnyx.com) portal to know more our APIs and how to integrate your software with us.
