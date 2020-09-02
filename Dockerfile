FROM ruby:2.7.1
ENV LANG C.UTF-8
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs
RUN mkdir /grow-api
WORKDIR /grow-api
ADD Gemfile /grow-api/Gemfile
ADD Gemfile.lock /grow-api/Gemfile.lock
RUN bundle install
ADD . /grow-api