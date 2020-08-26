
connect = {
  # Controls whether Connect features are enabled on this agent. Should be enabled on all
  # clients and servers in the cluster in order for Connect to function properly.
  # Defaults to false.
  enabled = true
}

ports {
  # Used to expose the xDS API to Envoy proxies.
  grpc = 8502
}

# When set, the Consul agent will look for any centralized service configurations that
# match a registering service instance. If it finds any, the agent will merge the
# centralized defaults with the service instance configuration. This allows for things
# like service protocol or proxy configuration to be defined centrally and inherited by
# any affected service registrations.
enable_central_service_config = true
