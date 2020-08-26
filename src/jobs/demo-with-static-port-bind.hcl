
/*

This job demonstrates setting up the app using a static port bind to
port 80 on the host with a bridged network.

The host sets up an iptables rule for port 80 to send the traffic to
the container.

The two containers sit within a network together on what appears as
a single network interface. Both containers open sockets that they
can then connect to via 127.0.0.1.

As nginx is exposed through a static port binding via nomad, a
registration with Consul is not required. No ingress gateway is used
so the services do not need to be discoverable.

A dynamic port bind could be used, but then the user would not know
what port to connect to each time it restarts.

To apply, run:
  nomad run /vagrant/src/jobs/demo-with-static-port-bind.hcl

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

      // Setup iptables nat forwarding rules to connect the container
      // using a static port.
      port "http" {
        static = 80
        to = 80
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
