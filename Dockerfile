# Pass in nodejs version
ARG NODE_VERSION=20.0.0

# Pass in ruby version
ARG RUBY_VERSION=3.2.2

# Pull in the nodejs image
FROM node:${NODE_VERSION}-alpine AS node

# Pull in relevant ruby image
FROM ruby:${RUBY_VERSION}-alpine

# As this is a multistage Docker image build
# we will pull in the contents from the previous node image build stage
# to our current ruby build image stage
# so that the ruby image build stage has the correct nodejs version
COPY --from=node /usr/lib /usr/lib
COPY --from=node /usr/local/share /usr/local/share
COPY --from=node /usr/local/lib /usr/local/lib
COPY --from=node /usr/local/include /usr/local/include
COPY --from=node /usr/local/bin /usr/local/bin

# Set the app directory
WORKDIR /app

# Install application dependencies
RUN apk add --update --no-cache \
  build-base \
  ca-certificates \
  curl \
  git \
  libpq-dev \
  npm \
  tzdata

RUN npm install -g yarn@1.22.19 --force

RUN yarn install --check-files

COPY . .

COPY Gemfile Gemfile.lock ./

# Build application
RUN gem install bundler && bundle install --jobs 4 --retry 5 --deployment

RUN NODE_OPTIONS=--openssl-legacy-provider rake assets:precompile

EXPOSE 3000

CMD ["rails", "server", "-b", "0.0.0.0"]