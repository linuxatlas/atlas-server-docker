FROM ubuntu

# user / group args
ARG UNAME=wine
ARG UID=1000
ARG GID=1000

# create wine user
RUN groupadd -g ${GID} -o ${UNAME}
RUN useradd -u ${UID} -g ${GID} -d /home/${UNAME} -m -s /bin/bash ${UNAME}
ENV HOME /home/${UNAME}
WORKDIR /home/${UNAME}

# wine env vars
ENV WINEPREFIX /home/${UNAME}/.wine
ENV WINEARCH win64
ENV WINEDEBUG -all

# START install

# non interactive installs
ENV DEBIAN_FRONTEND noninteractive

# add 32bit arch since we're on 64bit OS
RUN dpkg --add-architecture i386

RUN apt-get update && \
    apt-get upgrade -y && \
    # locales
    apt-get install -y --no-install-recommends locales && \
    sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    dpkg-reconfigure --frontend=noninteractive locales && \
    update-locale LANG=en_US.UTF-8 && \
    # basic deps
    apt-get install -y --no-install-recommends gpg-agent software-properties-common apt-transport-https wget && \
    apt-get install -y --no-install-recommends xvfb x11vnc xterm && \
    # redis
    apt-get install -y --no-install-recommends redis && \
    # add wine ppas
    wget -nc https://dl.winehq.org/wine-builds/winehq.key && \
    apt-key add winehq.key && \
    apt-add-repository 'deb https://dl.winehq.org/wine-builds/ubuntu/ bionic main' && \
    apt-get update && \
    # install wine and deps
    apt-get install -y --install-recommends winehq-devel && \
    apt-get install -y --no-install-recommends winbind && \
    su -p -l ${UNAME} -c 'winecfg && wineserver --wait' && \
    # steamcmd
    su -p -l ${UNAME} -c 'wget -qO- "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz" | tar zxvf -' && \
    # clean
    apt-get autoremove -y --purge software-properties-common && \
    apt-get autoremove -y --purge && \
    apt-get clean -y && \
    rm -rf /home/${UNAME}/.cache && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# END install

# locale env
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8

# VNC env
ENV DISPLAY :20

#Expose port 5920 to view display using VNC Viewer
EXPOSE 5920

CMD ["install-server"]

COPY ./bin /usr/local/bin
RUN chmod a+x /usr/local/bin/*

USER ${UNAME}