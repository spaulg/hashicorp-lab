
# Overview

A Hashicorp product lab that can be used for trying different setups
and deployments for Hashicorp products.

Creates a single server Nomad/Consul cluster with two clients for running
workloads via docker.

## Docker image build

First, on the host, create the docker images that will be used for the demo
app. They need to be built and exported to be shared amongst both client
nodes. 

```
docker build -t demo-fpm:master src/docker/fpm
docker save -o src/docker/demo-fpm.image demo-fpm:master

docker build -t demo-nginx:master src/docker/nginx
docker save -o src/docker/demo-nginx.image demo-nginx:master
```

## Vagrant plugins

The following Vagrant plugins must be installed:

```
vagrant plugin install vagrant-hostmanager 
``` 

## Environment start

Start the environment. The order shouldn't technically matter since it's
only a single server cluster, cluster formation should not be an issue.

```
vagrant up server1
vagrant up client1
vagrant up client2
```

## Load demo job

Load the demo job for running the demo app. This uses the previously built
docker images loaded in to each client's docker image store. Nomad docker
plugin settings have been updated to disable image gc cleanup.

```
vagrant ssh server1
nomad run /vagrant/src/jobs/demo/hcl
```

## Addresses

* http://server1.test:4646 - Nomad UI
* http://server1.test:8500 - Consul UI 

## Consul commands

Apply a configuration change to Consul

`consul config write <configfile>`

## Nomad commands

Run a job

`nomad run <jobfile>`

Stop a previously run job

`nomad stop <jobname>`

Run garbage collection immediately, cleaning up dead jobs

`nomad system gc`
