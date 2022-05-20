FROM ruby:2.7.0

RUN curl --silent --location https://deb.nodesource.com/setup_16.x | bash -
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN apt-get update -yqq && \
      apt-get install -y locales locales-all curl build-essential git-core imagemagick \
      libpq-dev libcurl4-openssl-dev libxslt-dev libssl-dev libyaml-dev libtool libpcre3 libpcre3-dev zlib1g zlib1g-dev libxml2-dev libreadline-dev libxslt1-dev software-properties-common libffi-dev parallel brotli advancecomp jhead jpegoptim libjpeg-turbo-progs optipng pngcrush pngquant nodejs yarn && \
      npm install -g terser &&\
      npm install -g uglify-js &&\
      npm install svgo

ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8

# Set an environment variable where the Rails app is installed to inside of Docker image
ENV RAILS_ROOT /app
RUN mkdir -p $RAILS_ROOT

# Set working directory
WORKDIR $RAILS_ROOT

# Setting env up
ENV RAILS_ENV production

RUN echo 'gem: --no-document' >> /usr/local/etc/gemrc && gem update --system

# Adding gems
COPY Gemfile  .
COPY Gemfile.lock .
RUN gem install bundler
ARG GITHUB_ACCESS_TOKEN
RUN bundle config github.com ${GITHUB_ACCESS_TOKEN}
RUN bundle && bundle install --jobs=10 --retry 5 --without development test
RUN yarn install --check-files --production && yarn cache clean

ADD install-oxipng /tmp/install-oxipng
RUN /tmp/install-oxipng

# Adding project files
COPY . ./
ARG DISCOURSE_REDIS_HOST
ARG DISCOURSE_SECRET_KEY_BASE
ARG DISCOURSE_DB_HOST
ARG DISCOURSE_DB_PORT
ARG DISCOURSE_DB_NAME
ARG DISCOURSE_DB_USERNAME
ARG DISCOURSE_DB_PASSWORD

ENV DISCOURSE_REDIS_HOST ${DISCOURSE_REDIS_HOST}
ENV DISCOURSE_SECRET_KEY_BASE ${DISCOURSE_SECRET_KEY_BASE}
ENV DISCOURSE_DB_HOST ${DISCOURSE_DB_HOST}
ENV DISCOURSE_DB_PORT ${DISCOURSE_DB_PORT}
ENV DISCOURSE_DB_NAME ${DISCOURSE_DB_NAME}
ENV DISCOURSE_DB_USERNAME ${DISCOURSE_DB_USERNAME}
ENV DISCOURSE_DB_PASSWORD ${DISCOURSE_DB_PASSWORD}

# RUN DISCOURSE_SECRET_KEY_BASE=${DISCOURSE_SECRET_KEY_BASE} DISCOURSE_REDIS_HOST=${DISCOURSE_REDIS_HOST} DISCOURSE_DB_HOST=${DISCOURSE_DB_HOST} DISCOURSE_DB_PORT=${DISCOURSE_DB_PORT} DISCOURSE_DB_NAME=${DISCOURSE_DB_NAME} DISCOURSE_DB_USERNAME=${DISCOURSE_DB_USERNAME} DISCOURSE_DB_PASSWORD=${DISCOURSE_DB_PASSWORD} bundle exec rake assets:precompile

EXPOSE 3000
