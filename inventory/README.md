# Example Inventory Host Configurations

Examples for configuring hosts file.

Single host.

```ini
pi01.bramble.local ansible_host=fe80::dd16:ac4e:a633:edbb%en0

[consul_instances]
pi01.bramble.local consul_node_role=server consul_bootstrap_expect=true

[vault_instances]
pi01.bramble.local

[nomad_instances]
pi01.bramble.local nomad_node_role=both
```

Two hosts.

```ini
pi01.bramble.local ansible_host=fe80::dd16:ac4e:a633:edbb%en0
pi02.bramble.local ansible_host=fe80::f2dd:3a36:39ca:91f1%en0

[consul_instances]
pi01.bramble.local consul_node_role=bootstrap
pi02.bramble.local consul_node_role=client

[vault_instances]
pi01.bramble.local
pi02.bramble.local

[nomad_instances]
pi01.bramble.local nomad_node_role=both
pi02.bramble.local nomad_node_role=client
```

Three hosts.

```ini
pi01.bramble.local ansible_host=fe80::dd16:ac4e:a633:edbb%en0
pi02.bramble.local ansible_host=fe80::f2dd:3a36:39ca:91f1%en0
pi03.bramble.local ansible_host=fe80::22c0:f3e7:514b:2b66%en0

[consul_instances]
pi01.bramble.local consul_node_role=bootstrap
pi02.bramble.local consul_node_role=client
pi03.bramble.local consul_node_role=client

[vault_instances]
pi01.bramble.local
pi02.bramble.local
pi03.bramble.local

[nomad_instances]
pi01.bramble.local nomad_node_role=both
pi02.bramble.local nomad_node_role=client
pi03.bramble.local nomad_node_role=client
```
