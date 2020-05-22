#!/bin/bash
# Set services to automatic start cpupower settings
# Rev 1.4.1 2020-05-21, jgmm81@gmail.com
# Tested on: Ubuntu 20.04LTS, 

CPUPOWER_PATH=/opt/cpuondemand
BASH_FILE="${CPUPOWER_PATH}/run_cpuondemand.sh"
SERVICE_FILE="${CPUPOWER_PATH}/cpupower.service"

#Set seconds to sleep according machine speed for wait to OS load
WAIT_SECONDS=25

#Default 1.80
MAX_CPU_GHZ=1.80

apt-get install -y linux-tools-common linux-tools-$(uname -r)

mkdir -p "${CPUPOWER_PATH}"

cat > "${BASH_FILE}" << EOL
#!/bin/bash
## for the CPU Governor and keep it running

LOG_FILE="${CPUPOWER_PATH}/startup.log"

echo "---------------------------" | tee >> "\${LOG_FILE}"
date | tee >> "\${LOG_FILE}"

#Set seconds to sleep according machine speed for wait to OS load
sleep ${WAIT_SECONDS}

apt-get install -y linux-tools-common linux-tools-\$(uname -r) 2>&1 | tee >> "\${LOG_FILE}"

/usr/bin/cpupower --cpu all frequency-set --max ${MAX_CPU_GHZ}GHz 2>&1 | tee >> "\${LOG_FILE}"

date | tee >> "\${LOG_FILE}"
echo "---------------------------" | tee >> "\${LOG_FILE}"
EOL

chmod 755 "${BASH_FILE}"

cat > "${SERVICE_FILE}" << EOL
[Unit]
Description=CPU ondemand

[Service]
Type=oneshot
ExecStart=/bin/bash ${BASH_FILE}

[Install]
WantedBy=multi-user.target
EOL

chmod 755 "${SERVICE_FILE}"

[[ ! -f /etc/systemd/system/cpupower.service ]] && ln -s ${SERVICE_FILE} /etc/systemd/system/cpupower.service

systemctl daemon-reload
systemctl start cpupower.service
systemctl enable cpupower.service
