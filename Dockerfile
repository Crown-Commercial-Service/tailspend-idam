FROM ruby:3.2.2-alpine

ARG NODE_MAJOR=20

WORKDIR /app

RUN apk add --update ca-certificates curl nodejs npm

RUN npm install -g yarn@1.22.19

COPY Gemfile Gemfile.lock ./

RUN yarn install --check-files

RUN gem install bundler && bundle install --jobs 20 --retry 5

COPY . .

RUN NODE_OPTIONS=--openssl-legacy-provider rake assets:precompile

EXPOSE 3000

CMD ["rails", "server", "-b", "0.0.0.0"]


# RUN apt-get update && \
#   apt-get install -y ca-certificates curl gnupg && \
#   mkdir -p /etc/apt/keyrings && \
#   curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg && \
#   echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list  && \
#   apt-get update && \
#   apt-get install -y nodejs && \
#   npm install -g yarn@1.22.19