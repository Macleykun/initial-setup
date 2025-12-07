initial-setup
=========

Set's up users, admins, keys and ssh so that ansible can be used with a key instead of password.

You need to do these steps beforehand on the control node/location you run playbooks from:

```bash
apt install sudo ansible -y
```

Optionally, in the cloned repo you can set your become password like so:

```bash
vim .becomepass # Add your pass now
chmod 0400 .becomepass
```

Role Variables
--------------

Use the following to setup a user as admin with their own public key so they can remote login.
```yml
change_hostname: False # Optional by default False
administrators:
  - username: macley
    groups: # Optional else the user will be added to their own group only
      - wheel
    shell: /bin/zsh # Optional
    pub_key: # Optional but pass auth is disallowed
      - ssh-ed25519 a comment
      - ssh-rsa blabla 2cool4school
```

Example Inventory
----------------
```ini
fqdn.domain.ext
shortname ansible_host=in.valid.ip.addr
tails ansible_host=in.valid.ip.addr motd_type=Tails # motd_type should be set in the host_vars hostname main.yml
kliko ansible_host=in.valid.ip.addr motd_type=kliko
```

Example Playbook
----------------

If used in a bigger play, it's best to execute only the tags or role tag.

```yaml
- name: Initial system setup
  become: True
  gather_facts: True
  hosts: fqdn.domain.ext
  vars:
    #ansible_ssh_common_args: '-o StrictHostKeyChecking=no' # Optional by default the hostkey will be checked
    change_hostname: False # Optional by default False
    administrators:
      - username: macley
        groups: # Optional else the user will be added to their own group only
          - wheel
        shell: /bin/zsh # Optional
        pub_key: # Optional but pass auth is disallowed
          - ssh-ed25519 a comment
          - ssh-rsa blabla 2cool4school
  tasks:
    - name: Initial Ansible setup
      ansible.builtin.import_role:
        role: initial-setup
      tags: init-setup
```

You can then run the playbook like so: `ansible-playbook init-setup.yml`

Just handy to know
----------------

If you get a hostkey checking issues, do this (assuming you have the private key, else just use password). It's assumed you want to connect to the localhost, but change the ip to the node you're connecting to.

`ssh -i ~/.ssh/id_ed25519_ansiblesetup $USER@127.0.0.1`

You can also configure the requirements.yml file if you ever need to keep track of dependencies!


And if you know a playbook will fail because of migration, make sure to append ` --force-handlers` as then everything that needs to be restarted will be!