FROM ubuntu:16.04

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install --yes --no-install-recommends \
    automake \
    bison \
    flex \
    g++ \
    git-core \
    inotify-tools \
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
  && rm --recursive --force /var/lib/apt/lists/* \
  && pip --no-cache-dir install conan==1.0.4 \
  && ln -sf /usr/bin/lua5.3 /usr/bin/lua

RUN mkdir /src \
  && wget --quiet -O /src/cmake.sh https://cmake.org/files/v3.10/cmake-3.10.2-Linux-x86_64.sh \
    && sh /src/cmake.sh --prefix=/usr/local --exclude-subdir --skip-license \
  && cd / \
  && rm --recursive --force /src

ENV HOME=/home/captain \
  CONAN_PRINT_RUN_COMMANDS=1
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


COPY start.sh /start.sh
ENTRYPOINT ["/start.sh"]
