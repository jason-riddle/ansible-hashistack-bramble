# Run the Hashistack on a Raspberry Pi Cluster

Inspired by https://github.com/geerlingguy/raspberry-pi-dramble and
https://github.com/mockingbirdconsulting/HashicorpAtHome with slight
modifications.

This project has three goals

    1. Run on Raspberry Pis
    2. Keep maintenance complexity as low as possible
    3. Make it easy to run docker containers on remote hosts

Installs and Configures Vault, Consul, and Nomad w/ Docker to run on a cluster
of Raspberry Pis. A cluster of Raspberry Pis can be referred to as a
[Bramble](https://elinux.org/Bramble). Thus the name
`ansible-hashistack-bramble`.

Optionally, the Amazon SSM agent can be installed for additional access,
monitoring, and control.

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [Quick Start Guide](#quick-start-guide)
  - [1 - Install dependencies](#1---install-dependencies)
  - [2 - Modify group variables](#2---modify-group-variables)
  - [3 - Configure to use a static IP](#3---configure-to-use-a-static-ip)
  - [4 - Discover hosts](#4---discover-hosts)
  - [5 - Apply all playbooks](#5---apply-all-playbooks)
  - [6 - Visit Dashboards](#6---visit-dashboards)
- [Consul DNS Queries](#consul-dns-queries)
  - [Querying Nodes](#querying-nodes)
  - [Querying Services](#querying-services)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Quick Start Guide

### 1 - Install dependencies

  1. Install [Ansible](http://docs.ansible.com/intro_installation.html).
  2. Install role dependencies: `make roles`

### 2 - Modify group variables

Place **non-sensitive** group variables in `inventory/group_vars` and
**sensitive** group variables in `vaulted_vars`.

### 3 - Configure to use a static IP

It's a good idea to configure your machine to use a static IP. For mac, this
requires configuring Ethernet under Network Settings. For example:

    Configure IPv4: Manually
    IP Address      10.0.100.59
    Subnet Mask:    255.255.255.0
    Router:         <empty>

### 4 - Discover hosts

Discover hosts by pinging the multicast address for all nodes. This assumes
devices you want to connect to and your computer are on the same bridge. For
mac, use the `en0` interface.

    ping6 -c2 -n ff02::1%en0

Then add these hosts to `inventory/hosts`. For example:

    pi01.bramble.local ansible_host=fe80::dd16:ac4e:a633:edbb%en0

    [consul_instances]
    pi01.bramble.local consul_node_role=server consul_bootstrap_expect=true

    [vault_instances]
    pi01.bramble.local

    [nomad_instances]
    pi01.bramble.local nomad_node_role=both

### 5 - Apply all playbooks

    # Optional: Ping all hosts first
    # make ping

    # Optional: Inspect wlan0 status
    # ansible all -i inventory -m shell -a '/sbin/ifconfig wlan0'

    # Configure Static Networking, WiFi, and Amazon SSM Agent
    make setup
    # Install and Configure Vault, Consul, and Nomad w/ Docker
    make main

### 6 - Visit Dashboards

Below is a table of how to locate dashboards.

| Description | URL                         |
|-------------|-----------------------------|
| Consul      | http://10.0.100.61:8500/ui/ |
| Vault       | http://10.0.100.61:8200/ui/ |
| Nomad       | http://10.0.100.61:4646/ui/ |

## Consul DNS Queries

Examples on how to query consul via dns.

### Querying Nodes

Query Format

    <node>.node[.datacenter].<domain>

Get the ip address of pi01.

    dig +short @127.0.0.1 -p 8600 pi01.node.homeserver.consul.

Ref: https://www.consul.io/docs/agent/dns.html#node-lookups

### Querying Services

Query Format

    [tag.]<service>.service[.datacenter].<domain>

Get the ip address of the active vault instance.

    dig +short @127.0.0.1 -p 8600 active.vault.service.homeserver.consul.

Ref: https://www.consul.io/docs/agent/dns.html#standard-lookup
