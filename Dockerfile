FROM ruby:2.7.4

WORKDIR /app

RUN curl -sL https://deb.nodesource.com/setup_14.x | bash - && \
  apt-get update && \
  apt-get install -y nodejs && \
  npm install -g yarn@1.22.19

COPY Gemfile Gemfile.lock ./

RUN yarn install --check-files

RUN gem install bundler && bundle install --jobs 20 --retry 5

COPY . .

RUN rake assets:precompile

EXPOSE 3000

CMD ["rails", "server", "-b", "0.0.0.0"]
