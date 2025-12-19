#!/bin/sh
set -eu

cd /
sudo /usr/bin/rm -f /var/lib/postgresql/14/main/postgresql.auto.conf
sleep 2
sudo systemctl restart postgresql