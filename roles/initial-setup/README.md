initial-setup
=========

Set's up users, admins, keys and ssh so that ansible can be used with a key instead of password.
Maybe one day if using some sort of portable ansible-navigator/playbook that it can also install and configure a system wide one.

Role Variables
--------------

Use the following to setup a user as admin with their own public key so they can remote login.
```yml
change_hostname: False # Optional by default False
hostname: fqdn # Optional but required if change_hostname is True (TODO: #1 in the future ansible_hostname will be used)
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

If used in a bigger play, it's best to execute only the tags and therefore you flushing the handlers is needed (i think)

```yaml
- name: Initial system setup
  become: True
  gather_facts: false
  hosts: fqdn.domain.ext
  vars:
    ansible_ssh_common_args: '-o StrictHostKeyChecking=no' # Optional by default the hostkey won't be checked
    change_hostname: False # Optional by default False
    hostname: fqdn
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
```

Author Information
------------------

Made by the Mac himself. Yeah i know that doesn't really spark confidence, reliance nor competence does it?
