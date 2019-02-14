FROM ruby:2.6

ENV LANG C.UTF-8

WORKDIR /masking

ADD Gemfile /masking/Gemfile
ADD Gemfile.lock /masking/Gemfile.lock

RUN bundle install

COPY . .
