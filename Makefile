export ANSIBLE_TIMEOUT=1

# Have ansible command output status in JSON
# export ANSIBLE_LOAD_CALLBACK_PLUGINS=true
# export ANSIBLE_STDOUT_CALLBACK=json

ping:
	ansible all -i inventory -m ping

setup:
	ansible-playbook -i inventory play_setup.yml --ask-vault-pass

main:
	ansible-playbook -i inventory play_main.yml --ask-vault-pass

roles:
	ansible-galaxy install -r requirements.yml --roles-path roles --force
.PHONY: roles

docs:
	doctoc README.md
