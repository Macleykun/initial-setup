# initial-setup
My Ansible role to setup a new server with users, admins, ssh keys including creating ssh keys specifically to manage the host to itself with ansible!

Make sure to install ansible, and sudo if you want to run this from your pre-created user: `apt install -y ansible sudo`.

You can use the `.ansible.cfg.example` to adjust ansible to your preference! Like setting the become pass and if you wish, the vaultpass! You create these files with your editor, only add the pass and lock it down to read permission to only your user only (0400)!

You do have to set the variables, you can do that in the host/group_vars/*yml or in the playbook itself.

```yaml
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

Or

```yaml
- name: Initial system setup
  become: True
  gather_facts: True
  hosts: fqdn.domain.ext
  vars:
    #ansible_ssh_common_args: '-o StrictHostKeyChecking=no' # Optional by default the hostkey will be checked
    change_hostname: False # Optional by default False
    administrators: # Ofcours you can put this part into the host/group_vars/*.yml aswell
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

Don't forget to configure your hosts.ini/inventory file properly!

```ini
tails ansible_host=in.valid.ip.addr motd_type=Tailsl
```

You can remove both variables, but motd_type will fall back to use the alligator2 font and withoud the ansible_host you must make the name be resolved to an ip yourself!


(-k for password auth, first time)(--private-key="~/.ssh/id_ed25519_ansiblesetup.old" for custom private key auth)

```bash
ansible-playbook init-setup.yml -l hostname
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

Futhermore, if you have an issue with host key checking, it's adviced to just accept the finterprint properly rather then disable this check: `ssh -i ~/.ssh/id_ed25519_ansiblesetup $USER@127.0.0.1`. Change the IP to the host you wish to connect to, and the $USER if you don't want to SSH into the host with the user you currently are.

If you ever need more collections where you use this role as a part of, you should make a requirements.yml file and install the collection like so: `ansible-galaxy collection install -r requirements.yml -p collections/ --force`.

```yaml
collections:
  - name: containers.podman
```

You may want to use `--force-handlers` if you know in your playb it'll fail. Maybe because you setup containers but need to manually migrate the data once. But then it would be handy to apply your handlers!

Also if you accidantly pusht your secrets to GitHub, you can do this to merge 3 commits into one:

```bash
git reset --soft HEAD~3
git commit -m "feat/fix: Whatdidyoufeatureaddorfix"
git push --force-with-lease origin main
```