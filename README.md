# initial-setup
My Ansible role to setup a new server!

To run it do:
```bash
ansible-playbook init-setup.yml -l hostname (-k for password auth, first time)(--private-key="~/.ssh/id_ed25519_ansiblesetup.old" for custom private key auth)
```

## How to quickly see all the facts:
```yaml
ansible all -m ansible.builtin.setup | less
```

Ofcours change all to whatever host you want. And do know you can get even more facts!
Do look at: https://docs.ansible.com/ansible/latest/collections/ansible/builtin/index.html
And search for `facts`! Some example's:
- ansible.builtin.package_facts module – Package information as facts
- ansible.builtin.service_facts module – Return service state information as fact data
