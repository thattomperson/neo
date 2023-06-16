FROM debian:stable-slim

LABEL org.opencontainers.image.description "Neovim for PHP remote dev"
LABEL org.opencontainers.image.source "https://github.com/thattomperson/neo"

ENV HOME="/root"
ENV PATH="${HOME}/n/bin:${PATH}"
ENV COMPOSER_ALLOW_SUPERUSER=1
# ENV EDITOR=nvim

RUN apt-get update && apt-get install -y \
  git ripgrep tini curl lua5.4 zsh fish python \
  php7.4 php7.4-bcmath php7.4-xml php7.4-curl \
  build-essential autoconf libtool \
  bison re2c pkg-config ninja-build gettext cmake unzip curl \
  libbz2-dev libpq-dev libxml2-dev libpng-dev sqlite3 libsqlite3-dev libssl-dev libcurl4-openssl-dev libjpeg-dev libonig-dev libreadline-dev libtidy-dev libxslt-dev libzip-dev \
  && rm -rf /var/lib/apt/lists/*

# NVIM doesn't ship a amd64 binary, so we have to build it ourselves
RUN git clone --depth 1 https://github.com/neovim/neovim --branch stable /usr/src/neovim && \
  cd /usr/src/neovim && make CMAKE_BUILD_TYPE=RelWithDebInfo && \
  make install;

# Install Lazygit cli
RUN LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*'); \
  curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_arm64.tar.gz"; \
  tar -xf lazygit.tar.gz lazygit; \
  rm lazygit.tar.gz; \
  chmod u+x lazygit; \
  mv lazygit /usr/bin/lazygit;

# Install tree-sitter cli
RUN curl -Lo tree-sitter.gz "https://github.com/tree-sitter/tree-sitter/releases/latest/download/tree-sitter-linux-arm64.gz"; \
  gunzip tree-sitter.gz; \
  chmod u+x tree-sitter; \
  mv tree-sitter /usr/bin/tree-sitter;

# Install composer
RUN EXPECTED_CHECKSUM="$(php -r 'copy("https://composer.github.io/installer.sig", "php://stdout");')" \
  php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
  ACTUAL_CHECKSUM="$(php -r "echo hash_file('sha384', 'composer-setup.php');")" \
  if [ "$EXPECTED_CHECKSUM" != "$ACTUAL_CHECKSUM" ] \
  then \
      >&2 echo 'ERROR: Invalid installer checksum' \
      rm composer-setup.php \
      exit 1 \
  fi \
  php composer-setup.php --quiet --filename=composer --install-dir=/usr/local/bin \
  RESULT=$? \
  rm composer-setup.php \
  exit $RESULT

# Install nodejs version manager
RUN curl -L https://bit.ly/n-install | bash -s -- -y;

# Install docker cli tool
ENV DOCKERVERSION=20.10.23
RUN curl -fsSLO https://download.docker.com/linux/static/stable/aarch64/docker-${DOCKERVERSION}.tgz \
  && tar xzvf docker-${DOCKERVERSION}.tgz --strip 1 \
                 -C /usr/local/bin docker/docker \
  && rm docker-${DOCKERVERSION}.tgz

# Copy the default config to the ~/.config/nvim folder
COPY . /root/.config/nvim

# Initalize nvim & install plugins
RUN nvim --headless -c 'quitall'
# Install LSPs and tools
RUN nvim --headless -c ':MasonInstallAll' -c 'quitall' || sleep 5;

# Set the /app dir as a valid git directory,
# This is just a QOL thing that we will probably do 99% of the time anyway
RUN git config --global --add safe.directory /app

WORKDIR /app
ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["nvim"]
