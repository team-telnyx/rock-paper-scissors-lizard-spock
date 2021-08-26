FROM hexpm/elixir:1.12.2-erlang-24.0.5-alpine-3.14.0 AS build

# prepare build dir
WORKDIR /app

# install hex + rebar
RUN mix local.hex --force && \
  mix local.rebar --force

# install build dependencies
RUN apk update && \
  apk upgrade --no-cache && \
  apk add --no-cache build-base zip git

# set build ENV
ENV MIX_ENV=prod

# install mix dependencies and build project
COPY mix.exs mix.lock ./
COPY config config
COPY lib lib
COPY priv priv
RUN mix do deps.get, deps.compile, compile

# build release
RUN mix release --overwrite

RUN cd /app/_build/prod/rel/call_control; zip --quiet -r /app/app.zip *

# prepare release image
FROM alpine:3.14.0 AS app

WORKDIR /app

RUN apk update && \
  apk upgrade --no-cache && \
  apk add --no-cache unzip ncurses libstdc++ libgcc

COPY --from=build /app/app.zip ./

RUN unzip -q app.zip

CMD /app/bin/call_control start
