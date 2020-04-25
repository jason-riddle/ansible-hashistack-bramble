# Sensitive Group Vars

Place all **sensitive and encrypted** variable files for roles and tasks in here.

Sensitive variable files should be encrypted with
[Ansible Vault](https://docs.ansible.com/ansible/latest/user_guide/vault.html).

The template `all_sensitive.yml.template` includes default variables to set.
Copy this file to `all_sensitive.yml`.

To encrypt this file

    ansible-vault encrypt all_sensitive.yml

To modify this file

    ansible-vault edit all_sensitive.yml
