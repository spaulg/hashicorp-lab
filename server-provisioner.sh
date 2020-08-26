#!/bin/bash
set -e

. /vagrant/init.sh

envsubst '$BIND_ADDRESS' < "/vagrant/src/config/nomad/nomad.sh" > /etc/profile.d/nomad.sh
chmod a+x /etc/profile.d/nomad.sh

# Server specific config
for config_file_path in /vagrant/src/config/consul/consul.server.d/*; do
    cat "$config_file_path" >> "/etc/consul.d/consul.hcl"
done

for config_file_path in /vagrant/src/config/nomad/nomad.server.d/*; do
    cat "$config_file_path" >> "/etc/nomad.d/nomad.hcl"
done

sudo systemctl restart nomad consul vault docker
