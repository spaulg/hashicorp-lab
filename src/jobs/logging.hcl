job logging {
  datacenters = ["dc1"]
  type = "service"

  // Testing constraint. Force all task deployments on to client1.
  constraint {
    attribute = "${node.unique.name}"
    value = "client1"
  }

  group "storage" {
    network {
      mode = "bridge"
    }

    service {
      name = "elasticsearch"
      port = "9200"

      // Add service mesh sidecar
      connect {
        sidecar_service { }
      }
    }

    task "elasticsearch" {
      driver = "docker"

      config {
        image = "elasticsearch:7.9.0"

        ulimit {
          memlock = "-1"
        }
      }

      // elasticsearch.service.consul
      // "discovery.seed_hosts" = "127.0.0.1"
      // "node.master" = "true"
      env {
        "node.name" = "es1"
        "cluster.name" = "logging"
        "bootstrap.memory_lock" = "true"
        "cluster.initial_master_nodes" = "es1"
      }

      resources {
        memory = 2048
      }

      // todo: production install considerations: https://www.elastic.co/guide/en/elasticsearch/reference/7.5/docker.html
      // todo: volume mount for perm storage
    }
  }

  group "collection" {
    network {
      mode = "bridge"
    }

    service {
      name = "logstash"
      port = "5000"

      // Add service mesh sidecar
      connect {
        sidecar_service {
          proxy {
            upstreams {
              destination_name = "elasticsearch"
              local_bind_port = "9200"
            }
          }
        }
      }
    }

    task "logstash" {
      // todo: configuration templates

      driver = "docker"

      config {
        image = "logstash:7.9.0"

        ulimit {
          memlock = "-1"
        }
      }

      resources {
        memory = 1024
      }
    }
  }

  group "analysis" {
    network {
      mode = "bridge"
    }

    service {
      name = "kibana"
      port = "5601"

      // Add service mesh sidecar
      connect {
        sidecar_service {
          proxy {
            upstreams {
              destination_name = "elasticsearch"
              local_bind_port = "9200"
            }
          }
        }
      }
    }

    task "kibana" {
      driver = "docker"

      config {
        image = "kibana:7.9.0"

        ulimit {
          memlock = "-1"
        }
      }

      env {
        ELASTICSEARCH_HOSTS = "http://127.0.0.1:9200"
      }

      resources {
        memory = 1024
      }
    }
  }
}
