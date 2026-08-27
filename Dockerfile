FROM ruby:3.3
LABEL authors="jugne"

# Install Node.js 18.x (LTS) - Required for Pagefind
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash -

RUN apt-get update -y && apt-get install -y --no-install-recommends  \
    build-essential \
    curl \
    git \
    libaio-dev \
    nodejs \
    texlive-latex-base texlive-fonts-recommended texlive-fonts-extra texlive-latex-extra \
    && rm -rf /var/lib/apt/lists/*

# Install Pagefind binary directly (npm wrapper fails on ARM64)
ARG PAGEFIND_VERSION=1.5.2
RUN ARCH=$(uname -m) && \
    if [ "$ARCH" = "aarch64" ] || [ "$ARCH" = "arm64" ]; then \
      PAGEFIND_ARCH="aarch64-unknown-linux-musl"; \
    else \
      PAGEFIND_ARCH="x86_64-unknown-linux-musl"; \
    fi && \
    curl -L "https://github.com/CloudCannon/pagefind/releases/download/v${PAGEFIND_VERSION}/pagefind-v${PAGEFIND_VERSION}-${PAGEFIND_ARCH}.tar.gz" | tar xz -C /usr/local/bin

ENV PAGE_HOME=/page

RUN mkdir -p $PAGE_HOME
WORKDIR $PAGE_HOME

# Install Ruby dependencies
COPY ./Gemfile* $PAGE_HOME/
RUN gem install bundler -v "4.0.18"
RUN bundle install

# Install Node.js dependencies
COPY package*.json $PAGE_HOME/
RUN npm install --ignore-scripts

# Verify installations
RUN ruby --version && \
    node --version && \
    npm --version && \
    pagefind --version
