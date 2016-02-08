# Kub-pyURDME

This repository contains scripts that setup a Kubernetes cluter in OpenStack and an application based on pyURDME framework. The framework can be found at http://pyurdme.github.io/pyurdme/ . The reposiory consists of three subdirectories:

## kubscripts

This is the script that lunch a Kubernates cluster in OpenStack. To run the cluster, the script assumes:
* The script must be lunched from one of the VMs in OpenStack
* The lunch VM must has access to all cluser nodes
* Users must have an IP list ready - a master node and worker nodes

Setting up the worker nodes takes a few seconds while the master node might take up to 10 minutes.

## docker-pyurdme

This directory contains a docker file that builds the image of pyURDME framework. 

## kub-h1-app

This directory contains HES1 application that can be loaded into a Kubernates cluster. The application has four components:
* A parameter generator : contains __pod__ configurations used to generate paramter sweeps and send them to a message broker (rabbitMQ)
* Hes1 Application: is a Celery distributed task worker that fetch a message from the broker and execute. This is application that consumes pyURDME framework.
* Message Broker: is used to store messages for distributed tasks.
* Flower: is a tool to manage Celery workers. 

Users will need to create all of the __yaml__ files in this repository by using the following order:
* Create message broker (both service and controller)
* Create HES1 application (only controller)
* Create Flower (both service and controller)
* Create Parameter Generator (only controller)

There are some port numbers that users will need to be opened in order to allow the Flower to be accessable from the outside. Users will need to check the default port numbers and change the IP address according to your nodes and network configurations in OpenStack.

