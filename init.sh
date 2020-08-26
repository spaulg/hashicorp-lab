#!/bin/bash
set -e

export DEBIAN_FRONTEND=noninteractive

# Install dependencies
sudo apt-get update
sudo apt-get install -y unzip curl jq dnsutils software-properties-common apt-transport-https ca-certificates make

# Add upstream vendor repositories
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository -n "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository -n "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"

curl -fsSL https://getenvoy.io/gpg | sudo apt-key add -
sudo add-apt-repository -n "deb [arch=amd64] https://dl.bintray.com/tetrate/getenvoy-deb $(lsb_release -cs) stable"

# Update and add pinned dependencies
sudo apt-get update
sudo apt-get install -y \
  nomad=0.12.3-2 \
  consul=1.8.3-2 \
  vault=1.5.2 \
  getenvoy-envoy=1.14.2.p0.g1a0363c-1p66.gfbeeb15 \
  docker-ce=5:19.03.12~3-0~ubuntu-focal

  # Add docker to vagrant group, for convenience
sudo usermod -aG docker vagrant

# Configure resolved to forward *.consul requests to the Consul service
install -d /etc/systemd/resolved.conf.d
cp /vagrant/src/config/resolved.conf.d/* /etc/systemd/resolved.conf.d/
sudo systemctl restart systemd-resolved

# The current version of networkd does not support non-standard DNS ports, so use iptables to forward them to the right port
sudo iptables -t nat -A OUTPUT -d localhost -p udp -m udp --dport 53 -j REDIRECT --to-ports 8600
sudo iptables -t nat -A OUTPUT -d localhost -p tcp -m tcp --dport 53 -j REDIRECT --to-ports 8600

# Download and install CNI networking plugins
# Needed to allow Nomad to configure private namespaced networks for task groups
curl -sSL -o cni-plugins.tgz https://github.com/containernetworking/plugins/releases/download/v0.8.6/cni-plugins-linux-amd64-v0.8.6.tgz
sudo mkdir -p /opt/cni/bin
sudo tar -C /opt/cni/bin -xzf cni-plugins.tgz

echo 1 > /proc/sys/net/bridge/bridge-nf-call-arptables
echo 1 > /proc/sys/net/bridge/bridge-nf-call-ip6tables
echo 1 > /proc/sys/net/bridge/bridge-nf-call-iptables

# Find IP address of private network
export BIND_ADDRESS=$(ip -4 addr show enp0s8 | grep -oP '(?<=inet\s)\d+(\.\d+){3}')

# Configure Consul
rm -f /etc/consul.d/consul.hcl

for config_file_path in /vagrant/src/config/consul/consul.all.d/*; do
    envsubst '$BIND_ADDRESS' < "$config_file_path" >> "/etc/consul.d/consul.hcl"
done

# Configure Nomad
rm -f /etc/nomad.d/nomad.hcl

for config_file_path in /vagrant/src/config/nomad/nomad.all.d/*; do
    envsubst '$BIND_ADDRESS' < "$config_file_path" >> "/etc/nomad.d/nomad.hcl"
done

# Configure docker daemon
cp /vagrant/src/config/docker/* /etc/docker/

# Enable services
sudo systemctl enable nomad consul vault docker

# Adjust sysctl limits
# For ES, this has to be applied on the host
sudo sysctl -w vm.max_map_count=262144
