#!/bin/bash
set -e

. /vagrant/init.sh

# Client specific config
for config_file_path in /vagrant/src/config/consul/consul.client.d/*; do
    cat "$config_file_path" >> "/etc/consul.d/consul.hcl"
done

for config_file_path in /vagrant/src/config/nomad/nomad.client.d/*; do
    cat "$config_file_path" >> "/etc/nomad.d/nomad.hcl"
done

sudo systemctl restart nomad consul vault docker
sleep 10

sudo consul join server1

docker load -i /vagrant/src/docker/demo-nginx.image
docker load -i /vagrant/src/docker/demo-fpm.image
