
# Protocol override for the elasticsearch service.
# The default protocol is tcp, but an ingress gateway for routing http traffic needs a
# protocol of http. At time of writing, the only way to configure this is as a Consul
# service default prior to the execution of the nomad job, though a change is in the
# pipeline to add support to nomad: https://github.com/hashicorp/nomad/issues/8647

Kind      = "service-defaults"
Name      = "elasticsearch"
Protocol  = "http"
