# syntax=docker/dockerfile:1
FROM --platform=${BUILDPLATFORM:-linux/amd64} cr.four.dev/four/php:7-all-dev
ARG TARGETARCH
ARG BUILDPLATFORM

LABEL org.opencontainers.image.description "Neovim for PHP remote dev"
LABEL org.opencontainers.image.source "https://github.com/thattomperson/neo"

ENV HOME="/root"
ENV COMPOSER_ALLOW_SUPERUSER=1

# Install nvim
RUN apk add --no-cache build-base cmake coreutils curl unzip gettext-tiny-dev bash tini perl fish ripgrep openjdk17;
RUN git clone --depth 1 https://github.com/neovim/neovim --branch stable /usr/src/neovim && \
  cd /usr/src/neovim && \
  make CMAKE_BUILD_TYPE=RelWithDebInfo && \
  make install && \
  rm -rf /usr/src/neovim

# Install Lazygit cli
RUN LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Eo '"tag_name": "v([^"])*' | cut -c15-); \
  case ${TARGETARCH} in \
    "amd64")  LAZYGIT_ARCH=x86_64  ;; \
    "arm64")  LAZYGIT_ARCH=arm64  ;; \
    *) echo "Invalid arch ${TARGETARCH}"; exit 1 ;; \
  esac; \
  curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_${LAZYGIT_ARCH}.tar.gz"; \
  tar -xf lazygit.tar.gz lazygit; \
  rm lazygit.tar.gz; \
  chmod u+x lazygit; \
  mv lazygit /usr/bin/lazygit;

# # Install nodejs
COPY --from=node:lts-alpine3.18 /usr/local/bin/node /usr/local/bin
COPY --from=node:lts-alpine3.18 /usr/local/lib/node_modules /usr/local/lib/node_modules
RUN ln -ns ../lib/node_modules/npm/bin/npm-cli.js /usr/local/bin/npm && \
  ln -ns ../lib/node_modules/npm/bin/npx-cli.js /usr/local/bin/npx && \
  ln -ns ../lib/node_modules/corepack/dist/corepack.js /usr/local/bin/corepack


# # Install docker cli tool
ENV DOCKERVERSION=20.10.23
RUN case ${TARGETARCH} in \
    "amd64")  DOCKER_ARCH=x86_64  ;; \
    "arm64")  DOCKER_ARCH=aarch64 ;; \
    *) echo "Invalid arch ${TARGETARCH}"; exit 1 ;; \
  esac; \
  curl -fsSLO "https://download.docker.com/linux/static/stable/${DOCKER_ARCH}/docker-${DOCKERVERSION}.tgz" \
  && tar xzvf docker-${DOCKERVERSION}.tgz --strip 1 \
                 -C /usr/local/bin docker/docker \
  && rm docker-${DOCKERVERSION}.tgz

ENV TZ=Australia/Adelaide
RUN apk add --no-cache tzdata; \
  echo "$TZ" >  /etc/timezone;

# # Copy the default config to the ~/.config/nvim folder
COPY lua /root/.config/nvim/lua
COPY init.lua /root/.config/nvim/init.lua
COPY bin /usr/local/bin

ARG CACHE_BUST

# # Initalize nvim & install plugins
RUN nvim --headless -c 'quitall'
# # Install LSPs and tools
RUN nvim --headless -c ':MasonInstallAll' -c 'quitall' || sleep 1;
RUN nvim --headless -c ':TSUpdate' -c 'quitall' || sleep 1;

# # Set the * as a valid git directory,
# # This is just a QOL thing that we will probably do 99% of the time anyway
RUN git config --global --add safe.directory "*"

RUN fish -c "curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher"
RUN fish -c "fisher install IlanCosman/tide@v5.3.0"
RUN fish -c "fisher install jhillyerd/plugin-git"

COPY data /root/.config/nvim/data

WORKDIR /app
ENTRYPOINT ["tini", "--"]
CMD ["nvim"]
