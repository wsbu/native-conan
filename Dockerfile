FROM ubuntu:16.04

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install --yes --no-install-recommends \
    automake \
    bison \
    flex \
    g++ \
    git-core \
    libtool \
    lua5.3 \
    make \
    openssh-client \
    pkg-config \
    python \
    python-pip \
    python-setuptools \
    python-wheel \
    sudo \
    wget \
  && rm --recursive --force /var/lib/apt/lists/*

RUN wget --quiet -O /tmp/cmake.sh https://cmake.org/files/v3.10/cmake-3.10.2-Linux-x86_64.sh \
  && sh /tmp/cmake.sh --prefix=/usr/local --exclude-subdir --skip-license \
  && rm /tmp/cmake.sh

ENV HOME=/home/captain

# Install Conan
RUN pip install conan==1.0.4
ENV CONAN_PRINT_RUN_COMMANDS=1
COPY conan/profile "${HOME}/.conan/profiles/default"
COPY conan/settings.yml "${HOME}/.conan/settings.yml"
COPY conan/registry.txt "${HOME}/.conan/registry.txt"

RUN groupadd --gid 1000 captain \
  && useradd --home-dir "$HOME" \
    --uid 1000 --gid 1000 \
    captain \
  && mkdir --parents \
    $HOME/.ssh \
  && chown --recursive captain:captain "$HOME" \
  && chmod --recursive 777 "$HOME" \
  && echo "ALL ALL=NOPASSWD: ALL" >> /etc/sudoers

# Scripts expect to run via "lua" command
RUN ln -sf /usr/bin/lua5.3 /usr/bin/lua

COPY start.sh /start.sh
ENTRYPOINT ["/start.sh"]
