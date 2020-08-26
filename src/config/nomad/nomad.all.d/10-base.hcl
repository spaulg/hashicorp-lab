
# Specifies a local directory used to store agent state. Client nodes use this directory
# by default to store temporary allocation data as well as cluster information. Server
# nodes use this directory to store cluster state, including the replicated log and
# snapshot data. This must be specified as an absolute path.
data_dir = "/opt/nomad/data"

# Specifies which address the Nomad agent should bind to for network services, including
# the HTTP interface as well as the internal gossip protocol and RPC mechanism. This
# should be specified in IP format, and can be used to easily bind all network services
# to the same address. It is also possible to bind the individual services to different
# addresses using the addresses configuration option.
#
# Warning: If using 0.0.0.0 as the bind address, Nomad appears to register the first
# network IP it finds on the host in Consul. If using Consul for service discovery, this
# may cause clients to be unable to find the servers if the IP is wrong, such as in
# Vagrant where the first IP is a private NAT network.
bind_addr = "$BIND_ADDRESS"
