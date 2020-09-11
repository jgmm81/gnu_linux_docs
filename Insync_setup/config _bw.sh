#!/bin/bash
# Insync config, prevent consume all Bandwidth
# Rev 1.0 2020-07-05, jgmm81@gmail.com
# Tested on: Ubuntu 20.04LTS with GNOME, 

apt install -y trickle sed

ACTUAL_USER=$(who | awk '{print $1}')

# Default Bandwidth (KB/sec): Download 256 / Upload 128
BW_MAX_DOWNLOAD=256
BW_MAX_UPLOAD=70

GNOME_DESKTOP_LAUNCHER=/usr/share/applications/insync.desktop
GNOME_AUTOSTART_LAUNCHER="/home/${ACTUAL_USER}/.config/autostart/insync.desktop"

TRICKLE_CONFIG="s/^Exec=.*$/Exec=trickle -d ${BW_MAX_DOWNLOAD} -u ${BW_MAX_UPLOAD} insync start/"

sed -i "${TRICKLE_CONFIG}" ${GNOME_DESKTOP_LAUNCHER}
[[ -f "${GNOME_AUTOSTART_LAUNCHER}" ]] && sed -i "${TRICKLE_CONFIG}" ${GNOME_AUTOSTART_LAUNCHER}

systemctl daemon-reload

