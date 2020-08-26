
client {
  # Specifies if client mode is enabled. All other client configuration options depend on
  # this value.
  enabled = true

  # Specifies the name of the interface to force network fingerprinting on. When run in
  # dev mode, this defaults to the loopback interface. When not in dev mode, the
  # interface attached to the default route is used. The scheduler chooses from these
  # fingerprinted IP addresses when allocating ports for tasks.
  network_interface = "enp0s8"
}
