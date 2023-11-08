# Pass in nodejs version
ARG NODE_VERSION=20.0.0

# Pull in the nodejs image
FROM node:${NODE_VERSION}-alpine AS node

# Pull in relevant ruby image
FROM ruby:3.2.2-alpine

# As it is a multistage build
# We will pull in the contents from the previous node image
# To our current ruby image
COPY --from=node /usr/lib /usr/lib
COPY --from=node /usr/local/share /usr/local/share
COPY --from=node /usr/local/lib /usr/local/lib
COPY --from=node /usr/local/include /usr/local/include
COPY --from=node /usr/local/bin /usr/local/bin

# Set the app directory
WORKDIR /app

# Install application dependencies
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

COPY . .

COPY Gemfile Gemfile.lock ./

RUN bundle install --jobs 20 --retry 5

RUN NODE_OPTIONS=--openssl-legacy-provider rake assets:precompile

EXPOSE 3000

CMD ["rails", "server", "-b", "0.0.0.0"]