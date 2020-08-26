
/*

This job demonstrates setting up the app using a sidecar proxy with
a dynamically allocated port, exposing port 80 via the service mesh
using an ingress gateway.

Nomad creates a second sidecar proxy container using envoy. This routes
traffic to the dynamic port to the nginx container.

The containers sit within a network together on what appears as
a single network interface. Both containers open sockets that they
can then connect to via 127.0.0.1.

The sidecar proxy and nginx containers are registered with Consul as
services.

An ingress gateway receives traffic using Envoy, with the sidecar
proxy acting as the upstream server, routing all traffic across the
service mesh.

To apply, run:
  consul config write /vagrant/src/config/consul/demo-service-defaults.hcl
  nomad run /vagrant/src/jobs/demo-with-ingress-gateway.hcl

  consul config write /vagrant/src/config/consul/http-ingress.hcl
  sudo consul connect envoy -gateway=ingress -register -service http-ingress -address 127.0.0.1:8888 -bind-address nginx=0.0.0.0

*/

job demo {
  datacenters = ["dc1"]
  type = "service"

  // Testing constraint. Force all task deployments on to client1.
  constraint {
    attribute = "${node.unique.name}"
    value = "client1"
  }

  group "app" {
    network {
      mode = "bridge"
    }

    // Consul service registration
    // Note that this does NOT apply on the task level.
    // It can only be placed at group level! Adding it to the
    // task level below will just get ignored but not error :o
    // This config will register a new service with Consul and
    // start a sidecar proxy that will connect traffic via a
    // dynamically allocated port to port 80 within the bridged
    // network, providing you're authorised to talk to it via
    // the service mesh.
    service {
      name = "nginx"
      port = "80"

      // Add service mesh sidecar
      connect {
        sidecar_service { }
      }
    }

    task "nginx" {
      driver = "docker"

      config {
        image = "demo-nginx:master"
      }

      env {
        // Set to apply as default virtual host.
        VIRTUAL_HOST = "_"

        // The bridged network combines all process namespaces in to a
        // single network interface. Running ss on either the nginx or
        // fpm process will show both ports 9000 & 80 listening.
        FASTCGI_HOST = "127.0.0.1:9000"
      }
    }

    task "fpm" {
      driver = "docker"

      config {
        image = "demo-fpm:master"
      }
    }
  }
}
