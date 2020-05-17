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
