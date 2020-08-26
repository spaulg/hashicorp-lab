
# data_dir
# This flag provides a data directory for the agent to store state. This is required
# for all agents. The directory should be durable across reboots. This is especially
# critical for agents that are running in server mode as they must be able to persist
# cluster state. Additionally, the directory must support the use of filesystem
# locking, meaning some types of mounted folders (e.g. VirtualBox shared folders) may
# not be suitable.
data_dir = "/opt/consul/data"

# bind_addr
# The address that should be bound to for internal cluster communications. This is an
# IP address that should be reachable by all other nodes in the cluster. By default,
# this is "0.0.0.0", meaning Consul will bind to all addresses on the local machine and
# will advertise the private IPv4 address to the rest of the cluster. If there are
# multiple private IPv4 addresses available, Consul will exit with an error at startup.
# If you specify "[::]", Consul will advertise the public IPv6 address. If there are
# multiple public IPv6 addresses available, Consul will exit with an error at startup.
# Consul uses both TCP and UDP and the same port for both. If you have any firewalls, be
# sure to allow both protocols. In Consul 1.0 and later this can be set to a go-sockaddr
# template that needs to resolve to a single address.
bind_addr = "$BIND_ADDRESS"
