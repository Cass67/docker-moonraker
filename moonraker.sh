#!/usr/bin/env bash
 
docker run \
    -v /dev:/dev \
    -v "/home/cass/git/3d_print_server/moonraker/config/moonraker.conf":/home/klippy/printer_data/config/moonraker.conf \
    --name moonraker \
    moonraker
