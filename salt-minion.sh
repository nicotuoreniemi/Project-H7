#!/bin/bash

apt-get -y install salt-minion

echo "master: 192.168.1.9" >> /etc/salt/minion
echo "id: $(hostname)" >> /etc/salt/minion

systemctl restart salt-minion.service

