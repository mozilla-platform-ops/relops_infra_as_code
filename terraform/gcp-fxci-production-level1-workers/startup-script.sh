#!/bin/bash

echo START_startup-script-proj

date > /home/ubuntu/startup_executed

sed -i.bak s/aws/google/ /etc/start-worker.yml 2>/dev/null
sed -i.bak s/aws/google/ /etc/taskcluster/worker-runner/start-worker.yml 2>/dev/null

chmod ugo+rw /home/ubuntu/worker.cfg 2>/dev/null
grep configPath /etc/start-worker.yml 2>/dev/null

chmod ugo+rw /etc/taskcluster/docker-worker/config.yml 2>/dev/null
grep configPath /etc/taskcluster/worker-runner/start-worker.yml 2>/dev/null

# logging

# cloudinit logging
sed -i '/^&/!{q1}; s/^&/#/' /etc/rsyslog.d/21-cloudinit.conf \
 && sed -i '/cloud-init-output.log/!{q1}; s/cloud-init-output.log/cloud-init.log/' /etc/cloud/cloud.cfg.d/05_logging.cfg \
 && service rsyslog restart

sleep 60

sudo grep -iv 'token\|secret"' /home/ubuntu/worker.cfg 2>/dev/null
sudo grep -iv 'token\|secret"' /etc/taskcluster/docker-worker/config.yml 2>/dev/null

ps -faux | grep "$(printf "%s\|" $(pgrep --full 'docker-worker'))docker-worker"

echo END_startup-script-proj
