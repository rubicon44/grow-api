FROM ruby:2.7.7

RUN apt-get update && \
    apt-get install -y build-essential \
                       libmariadb-dev-compat

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