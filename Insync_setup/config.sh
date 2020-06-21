#!/bin/bash
# Insync config, prevent consume all Bandwidth and CPU Resources 
# Rev 1.1.1 2020-05-21, jgmm81@gmail.com
# Tested on: Ubuntu 20.04LTS with GNOME, 

apt install -y trickle cpulimit sed

ACTUAL_USER=$(who | awk '{print $1}')

#In percent, default is 30
CPU_MAX_USAGE=30

# Default Bandwidth (KB/sec): Download 256 / Upload 128
BW_MAX_DOWNLOAD=256
BW_MAX_UPLOAD=70

GNOME_DESKTOP_LAUNCHER=/usr/share/applications/insync.desktop
GNOME_AUTOSTART_LAUNCHER="/home/${ACTUAL_USER}/.config/autostart/insync.desktop"

TRICKLE_CONFIG="s/^Exec=.*$/Exec=trickle -d ${BW_MAX_DOWNLOAD} -u ${BW_MAX_UPLOAD} insync start/"

sed -i "${TRICKLE_CONFIG}" ${GNOME_DESKTOP_LAUNCHER}
[[ -f "${GNOME_AUTOSTART_LAUNCHER}" ]] && sed -i "${TRICKLE_CONFIG}" ${GNOME_AUTOSTART_LAUNCHER}

###CPU Limit -> make service autosart ####

INSYNC_PATH=/opt/cpuusage/insync
BASH_FILE="${INSYNC_PATH}/insync_cpu_usage.sh"
SERVICE_FILE="${INSYNC_PATH}/insync_cpu_usage.service"

mkdir -p "${INSYNC_PATH}"

cat > "${BASH_FILE}" << EOL
#!/bin/bash
## CPU max usage for insync

LOG_FILE=${INSYNC_PATH}/cpulimit_errors.log

echo "---------------------------" | tee >> "\${LOG_FILE}"
date | tee >> "\${LOG_FILE}"

cpulimit -e insync -l ${CPU_MAX_USAGE} -b -q 2>&1 | tee >> "\${LOG_FILE}"

echo "---------------------------" | tee >> "\${LOG_FILE}"
EOL

chmod 755 "${BASH_FILE}"

cat > "${SERVICE_FILE}" << EOL
[Unit]
Description=CPU Limit for insync

[Service]
Type=oneshot
ExecStart=/bin/bash ${BASH_FILE}

[Install]
WantedBy=multi-user.target
EOL

chmod 755 "${SERVICE_FILE}"

[[ ! -f /etc/systemd/system/insync_cpu_usage.service ]] && ln -s ${SERVICE_FILE} /etc/systemd/system/insync_cpu_usage.service

systemctl daemon-reload
###systemctl start insync_cpu_usage.service
systemctl enable insync_cpu_usage.service

