FROM ruby:2.7.7

# RUN apt-get update && \
#     apt-get install -y curl && \
#     curl -LO https://releases.hashicorp.com/terraform/1.0.8/terraform_1.0.8_linux_amd64.zip && \
#     unzip terraform_1.0.8_linux_amd64.zip && \
#     mv terraform /usr/local/bin && \
#     rm terraform_1.0.8_linux_amd64.zip

# RUN apt-get clean && \
#     rm -rf /var/lib/apt/lists/*

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