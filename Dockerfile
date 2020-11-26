FROM ruby:2.7.1-alpine
RUN apk update && \
    apk upgrade && \
    apk add --no-cache \
    build-base \
    mariadb-dev \
    tzdata \
    nodejs
RUN mkdir /grow-api
ENV APP_ROOT /grow-api
WORKDIR $APP_ROOT
ADD Gemfile $APP_ROOT/Gemfile
ADD Gemfile.lock $APP_ROOT/Gemfile.lock
RUN bundle install
ADD . $APP_ROOT

RUN mkdir -p tmp/sockets tmp/pids
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["sh", "entrypoint.sh"]