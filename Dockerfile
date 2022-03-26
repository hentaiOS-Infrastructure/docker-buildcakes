FROM debian:testing-slim
LABEL maintainer="Rapherion Rollerscaperers <raphielscape@raphielgang.org>"

ENV DEBIAN_FRONTEND=noninteractive \
    USER=docker \
    HOSTNAME=buildbot \
    USE_CCACHE=1 \
    CCACHE_DIR=/tmp/ccache

# Install required dependencies
RUN sed -r -i 's/^deb(.*)$/deb\1 contrib/g' /etc/apt/sources.list && \
    apt-get update && \
    apt-get install --no-install-recommends -y \
        autoconf automake axel bc bison build-essential ccache clang cmake expat flex g++ g++-multilib gawk gcc gcc-multilib \
        gnupg gperf htop imagemagick lib32ncurses5-dev lib32z1-dev libtinfo5 libc6-dev libcap-dev libexpat1-dev \
        libgmp-dev liblz4-* liblzma* libmpc-dev libmpfr-dev libncurses5-dev libsdl1.2-dev libssl-dev libtool libxml2 \
        libxml2-utils lzma* lzop maven ncftp ncurses-dev patch patchelf pkg-config pngcrush pngquant python3 python-all-dev \
        re2c schedtool squashfs-tools subversion texinfo unzip w3m xsltproc zip zlib1g-dev curl git sudo rsync openssl \
        gnutls-bin libncurses5 bsdmainutils repo && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# HACK HACK HACK HACK
# Symlink python3 to python to workaround repo breakage
RUN ln -s /usr/bin/python3 /usr/bin/python

# Create seperate build user
RUN groupadd -g 999 -r ${USER} && \
    useradd -u 999 --create-home -r -g ${USER} ${USER} --shell /bin/bash
RUN mkdir -p /tmp/ccache /repo && \
    chown -R ${USER}: /tmp/ccache /repo

# Allow sudo without password for build user
RUN echo "${USER} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/90-docker-build && \
    usermod -aG sudo ${USER}

# Setup volumes for persistent data
USER ${USER}
VOLUME ["/tmp/ccache", "/repo"]

# Create gitconfig for build user
RUN git config --global user.name ${USER} && git config --global user.email ${USER}@${HOSTNAME}.local && \
    git config --global color.ui auto

# Work in the build directory, repo is expected to be init'd here
WORKDIR /repo

# This is where the magic happens~
ENTRYPOINT ["/bin/bash"]
