# Container for moonraker
#
# -- build container as per whatever arch is needed --
# docker buildx build --platform linux/amd64 -t moonraker .   # << x86
# docker buildx build --platform linux/aarch64 -t moonraker . # << m1 mac
#
# or if you dont care about arch related stuff
#
# docker build -t moonraker .
#
# -- export container for another system --
# docker save -o moonraker.tar moonraker
# gzip moonraker.tar
#
#
# -- RUN --
#     docker run \
#       -v /dev:/dev \
#       -v "/home/cass/home_klippy/klippy":/home/klippy \
#       -v /dev/ttyUSB0:/dev/serial/by-id/usb-1a86_USB_Serial-if00-port0 \
#       --name moonraker \
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
#       moonraker
# }



FROM debian:10

ENV container docker
ENV LC_ALL C
ENV DEBIAN_FRONTEND noninteractive

# Install systemd dependencies + sudo/git
RUN apt-get update \
    && apt-get install -y \
    python3-virtualenv \ 
    python3-dev \ 
    python3-libgpiod \ 
    liblmdb-dev \
    libopenjp2-7 \ 
    libsodium-dev \ 
    zlib1g-dev \ 
    libjpeg-dev \ 
    packagekit \
    wireless-tools \
    curl \
    git \
    python3-pip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*


# Create user
RUN useradd -ms /bin/bash klippy && adduser klippy dialout
USER root
RUN echo 'klippy ALL=(ALL:ALL) NOPASSWD: ALL' > /etc/sudoers

USER klippy
#This fixes issues with the volume command setting wrong permissions
RUN mkdir -p /home/klippy/.config /home/klippy/printer_data/config /home/klippy/logs
VOLUME /home/klippy/.config

ENV HOMEDIR=/home/klippy
### Klipper setup ###
WORKDIR /home/klippy
USER klippy
RUN git clone https://github.com/Arksine/moonraker.git
COPY requirements.txt .
RUN pip3 install -r requirements.txt

EXPOSE 7125
ENTRYPOINT ["/usr/bin/python3", "/home/klippy/moonraker/moonraker/moonraker.py", "-d", "/home/klippy/printer_data"]


