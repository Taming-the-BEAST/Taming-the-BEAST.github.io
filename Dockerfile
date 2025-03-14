FROM ruby:3.0
LABEL authors="jugne"

RUN apt-get update -y && apt-get install -y --no-install-recommends  \
    build-essential \
    curl \
    git \
    libaio-dev \
    nodejs \
    texlive-latex-base texlive-fonts-recommended texlive-fonts-extra texlive-latex-extra

ENV PAGE_HOME /page

RUN mkdir -p $PAGE_HOME
WORKDIR $PAGE_HOME

COPY ./Gemfile* $PAGE_HOME/
RUN gem install bundler -v "2.3.13"
RUN bundle install
