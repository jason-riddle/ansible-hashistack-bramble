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
  - [Copy Logs to Host Machine](#copy-logs-to-host-machine)
- [Bonus: Custom Raspbian Image](#bonus-custom-raspbian-image)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Quick Start Guide

### 1 - Install dependencies

  1. Install [Ansible](http://docs.ansible.com/intro_installation.html).
  2. Install role dependencies: `make roles`

### 2 - Modify group variables

Place **non-sensitive** group variables in `inventory/group_vars` and
**sensitive** group variables in `vaulted_vars`.

For datadog configuration, create a `vaulted_vars/datadog_sensitive.yml` file
and add the following

    datadog_api_key: "DATADOG_API_KEY"

For nomad configuration, create a `vaulted_vars/nomad_sensitive.yml` file
and add the root vault token after vault has been initialized

    nomad_vault_token: "VAULT_ROOT_TOKEN"

For amazon ssm agent configuration, create a `vaulted_vars/ssm_agent_sensitive.yml`
file and add the following

    amazon_ssm_ec2_region: "SSM_REGION"
    amazon_ssm_activation_code: "SSM_ACTIVATION_CODE"
    amazon_ssm_activation_id: "SSM_ACTIVATION_ID"

For wifi configuration, create a `vaulted_vars/wpa_supplicant_sensitive.yml`
file and add your wifi configuration

    wpa_networks:
      - ssid: ROUTER_SSID
        psk: ROUTER_PASSWORD

### 3 - Configure to use a static IP

It's required to configure your machine to use a static IP. For mac, this
requires configuring Ethernet under Network Settings. For example:

    Configure IPv4: Manually
    IP Address      10.0.100.59
    Subnet Mask:    255.255.255.0
    Router:         <empty>

    Configure IPv6: Link-local only

### 4 - Discover hosts

Discover hosts by pinging the multicast address for all nodes. This assumes
devices you want to connect to and your computer are on the same bridge. For
mac, use the `en0` interface and use the following to identify ipv6 hosts

    myself=$(ifconfig en0 | grep -w 'inet6' | awk '{print $2}')
    ipv6_hosts=$(ping6 -c2 -I en0 ff02::1 | grep icmp_seq | grep -v $myself | cut -d, -f1 | awk '{print $NF}')
    echo $ipv6_hosts

Then add these hosts to `inventory/hosts`. For example:

    pi01.bramble.local ansible_host=fe80::dd16:ac4e:a633:edbb%en0

    [consul_instances]
    pi01.bramble.local consul_node_role=server consul_bootstrap_expect=true

    [vault_instances]
    pi01.bramble.local

    [nomad_instances]
    pi01.bramble.local nomad_node_role=both

Update `inventory/group_vars/all.yml` with the `eth0` mac address, hostname, and static ip

    mac_address_mapping:
      "b8:27:eb:21:e8:fd":
        hostname: "pi01"
        ip: "10.0.100.61"

See [inventory/README.md](inventory/README.md) for additional host configurations

### 5 - Apply all playbooks

    # Optional: Ping all hosts first
    # make ping

    # Optional: Inspect wlan0 status
    # ansible all -i inventory -m shell -a '/sbin/ifconfig wlan0'

    # Configure Static Networking, WiFi, and Amazon SSM Agent
    make setup
    # Install and Configure Vault, Consul, and Nomad w/ Docker
    make main

Vault will need to be unsealed if already initialized. Visit

    http://10.0.100.61:8500/ui/homeserver/services/vault

to list all of the vault instances and unseal each instance

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

### Copy Logs to Host Machine

It's easier to analyze logs on your desktop than over SSH. Copy logs to your
desktop machine from `pi01` with the following commands

    ssh pi@pi01 "sudo tar cvzf - /var/log" > var_logs.tar.gz
    ssh pi@pi01 "sudo -- sh -c 'find /var/lib/docker/containers -name '*.log' -print0 | xargs -0 tar cvzf -'" > containers_logs.tar.gz

## Bonus: Build Custom Raspbian Image with Packer

Can be paired with https://github.com/jason-riddle/packer-build-raspbian-os
for creating custom Raspbian OS images.
