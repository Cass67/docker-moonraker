
# Container for klipper
#
# -- build container as per whatever arch is needed --
# docker buildx build --platform linux/amd64 -t klipper .   # << x86
# docker buildx build --platform linux/aarch64 -t klipper . # << m1 mac
#
# or if you dont care about arch related stuff
#
# docker build -t klipper .
#
# -- export container for another system --
# docker save -o klipper.tar klipper
# gzip klipper.tar
#
#
# -- RUN --
#     docker run \
#       -v /dev:/dev \
#       -v "/home/cass/home_klippy/klippy":/home/klippy \
#       -v /dev/ttyUSB0:/dev/serial/by-id/usb-1a86_USB_Serial-if00-port0 \
#       --name klipper \
#       -p 80:80 \
#       -p 81:81 \
#       -p 5000:5000 \
#       -p 7125:7125 \
#       -p 8080:8080 \
#       --tmpfs /tmp \
#       --tmpfs /run \
#       --tmpfs /run/lock \
#       --privileged \
#       -v /sys/fs/cgroup:/sys/fs/cgroup:ro \
#       klipper
# }



FROM debian:10

ENV container docker
ENV LC_ALL C
ENV DEBIAN_FRONTEND noninteractive

# Install systemd dependencies + sudo/git
RUN apt-get update \
    && apt-get install -y systemd systemd-sysv procps vim \
    sudo git \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN cd /lib/systemd/system/sysinit.target.wants/ \
    && ls | grep -v systemd-tmpfiles-setup | xargs rm -f $1

RUN rm -f /lib/systemd/system/multi-user.target.wants/* \
    /etc/systemd/system/*.wants/* \
    /lib/systemd/system/local-fs.target.wants/* \
    /lib/systemd/system/sockets.target.wants/*udev* \
    /lib/systemd/system/sockets.target.wants/*initctl* \
    /lib/systemd/system/basic.target.wants/* \
    /lib/systemd/system/anaconda.target.wants/* \
    /lib/systemd/system/plymouth* \
    /lib/systemd/system/systemd-update-utmp*

VOLUME [ "/sys/fs/cgroup" ]

CMD ["/lib/systemd/systemd"]

ENV TZ=Europe/Prague
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Create user
RUN useradd -ms /bin/bash klippy && adduser klippy dialout
USER klippy

#This fixes issues with the volume command setting wrong permissions
RUN mkdir /home/klippy/.config
VOLUME /home/klippy/.config

### Klipper setup ###
WORKDIR /home/klippy

USER root

RUN echo 'klippy ALL=(ALL:ALL) NOPASSWD: ALL' > /etc/sudoers.d/klippy
# This is to allow the install script to run without error

USER klippy

RUN git clone https://github.com/Klipper3d/klipper.git


USER root