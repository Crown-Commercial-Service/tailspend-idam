ARG NODE_VERSION=20.0.0

#FROM ruby:3.2.2-alpine AS base

FROM node:${NODE_VERSION}-alpine AS node

FROM ruby:3.2.2-alpine

COPY --from=node /usr/lib /usr/lib
COPY --from=node /usr/local/share /usr/local/share
COPY --from=node /usr/local/lib /usr/local/lib
COPY --from=node /usr/local/include /usr/local/include
COPY --from=node /usr/local/bin /usr/local/bin

# COPY --from=base /usr/local/bundle /usr/local/bundle

RUN apk add --update --no-cache \
  npm \
  ca-certificates \
  build-base \
  libpq-dev \
  git \
  tzdata

RUN npm install -g yarn@1.22.19 --force

RUN yarn install --check-files

RUN gem install bundler

WORKDIR /app

COPY . .

COPY Gemfile Gemfile.lock ./

RUN bundle install --jobs 20 --retry 5

RUN NODE_OPTIONS=--openssl-legacy-provider rake assets:precompile

EXPOSE 3000

CMD rm -f tmp/pid/server.pid & rails s -b '0.0.0.0'


# RUN apt-get update && \
#   apt-get install -y ca-certificates curl gnupg && \
#   mkdir -p /etc/apt/keyrings && \
#   curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg && \
#   echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list  && \
#   apt-get update && \
#   apt-get install -y nodejs && \
#   npm install -g yarn@1.22.19