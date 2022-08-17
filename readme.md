# study-ansible

# Introduction
Ansible is a tool for managing servers in order to control their desired state by means of a desired state configuration. Ansible uses Python on both the control node (CN) and the Hosts/Servers (H) and uploads Python modules to the server and executes them. Ansible uses SSH and SSH-keys for the deliverance of these Python modules. Both requirements mean that you should have:

- Python 3 on your CN and H
- SSH enabled with SSH-keys configured
- Network setup that allows connections from the CN to port 22
- Network routing setup so that all the H are reachable 

Ansible manages the desired state of servers. Lets call these servers Hosts (H). The desired state configuration is written in yaml format. To come to the desired state, we often have to configure the servers step-by-step as a list of tasks. These list of tasks are called a Play (P) and if you create a yaml file that contains this list of tasks, the file is called a [PlayBook (PB)](https://docs.ansible.com/ansible/latest/reference_appendices/playbooks_keywords.html).    

Ansible contains modules that will be uploaded and executed on the target hosts. There are [hundreds of modules available](https://docs.ansible.com/ansible/latest/collections/index_module.html), from the standard [builtin](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/index.html) that contains the modules standard modules like debug, copy, find, apt, and much more, to [amazon.aws modules](https://docs.ansible.com/ansible/latest/collections/index_module.html#amazon-aws) to [community.mysql](https://docs.ansible.com/ansible/latest/collections/index_module.html#community-mysql), the list goes on and on. 

Besides modules, Ansible can be extended by means of [plugins](https://docs.ansible.com/ansible/latest/plugins/plugins.html). This enables Ansible's feature set to be extended by means of configuration. Plugins must be enabled and configured and can then be used.  

Ansible is very well documented and comes with a [user guide](https://docs.ansible.com/ansible/latest/user_guide/index.html), but still you need to learn to navigate the website and read through some documentation for the available modules and plugins in order to get used to the format and also to get to grips with the available configuration items per module. 

## Available commands

Ansible has a number of CLI utilities. Mostly we will be using `ansible-playbook` and `ansible-inventory`:

| command           | description                                                                             | example                                                                               |
|-------------------|-----------------------------------------------------------------------------------------|:--------------------------------------------------------------------------------------|
| ansible           | Define and run a single task 'playbook' against a set of hosts                          |                                                                                       |
| ansible-config    | View ansible configuration                                                              | ansible-config list, ansible-config dump                                              |      
| ansible-galaxy    | Perform various Role and Collection related operations                                  | ansible-galaxy collection list                                                        |
| ansible-inventory | Show Ansible inventory information, by default it uses the inventory script JSON format | ansible-inventory --graph, ansible-inventory --list                                   |
| ansible-playbook  | Runs Ansible playbooks, executing the defined tasks on the targeted hosts               | ansible-playbook ping-playbook.yml -u ec2-user --private-key ../00-create-ec2/keypair |
| ansible-pull      | pulls playbooks from a VCS repo and executes them for the local host                    |                                                                                       |
| ansible-vault     | encryption/decryption utility for Ansible data files                                    |                                                                                       |
| ansible-doc       | plugin documentation tool                                                               | ansible-doc -l -t lookup                                                              |

## Ansible configuration

The [ansible configuration is well documented](https://docs.ansible.com/ansible/latest/reference_appendices/config.html), but the short of it is that Ansible searches for its configuration in the following order and will ignore all others if the first one is found. Which means that an ansible project directory is a standalone project if it contains an `ansible.cfg` file in there, and you execute an ansible command in that directory.

- `ANSIBLE_CONFIG` (environment variable if set)
- `./ansible.cfg` (in the current directory)
- `~/.ansible.cfg` (in the home directory)
- `/etc/ansible/ansible.cfg`

To support working with Ansible configuration, there is the [ansible-config](https://docs.ansible.com/ansible/latest/cli/ansible-config.html#ansible-config) tool that can list the available configuration options. 

## Variables

Ansible uses [variables](https://docs.ansible.com/ansible/latest/user_guide/playbooks_variables.html) to manage differences between systems. With Ansible, you can execute tasks and playbooks on multiple different systems with a single command. To represent the variations among those different systems, you can create variables with standard YAML syntax, including lists and dictionaries. You can define these variables in your playbooks, in your inventory, in re-usable files or roles, or at the command line. You can also create variables during a playbook run by registering the return value or values of a task as a new variable.

In general, Ansible gives precedence to variables that were defined more recently, more actively, and with more explicit scope. Variables in the defaults folder inside a role are easily overridden. Anything in the vars directory of the role overrides previous versions of that variable in the namespace. Host and/or inventory variables override role defaults, but explicit includes such as the vars directory or an include_vars task override inventory variables.

Where you set variables is important and there are [variable precedence rules](https://docs.ansible.com/ansible/latest/user_guide/playbooks_variables.html#ansible-variable-precedence):

Here is the order of precedence from **least** to greatest (the last listed variables override all other variables):

**LEAST**
- command line values (for example, -u my_user, these are not variables)
- role defaults (defined in role/defaults/main.yml)
- inventory file or script group vars
- inventory group_vars/all
- playbook group_vars/all
- inventory group_vars/*
- playbook group_vars/*
- inventory file or script host vars
- inventory host_vars/*
- playbook host_vars/*
- host facts / cached set_facts
- play vars
- play vars_prompt
- play vars_files
- role vars (defined in role/vars/main.yml)
- block vars (only for tasks in block)
- task vars (only for the task)
- include_vars
- set_facts / registered vars
- role (and include_role) params
- include params
- extra vars (for example, -e "user=my_user")(always win precedence)
**GREATEST**

## Loading variables explicitly

We can optionally load variables explicitly by having a `var-loader.yml` playbook that loads the variables from a path:

```yaml
---
- name: Get Vars for {{ env }}-{{ system }}-{{ subsystem }}
  hosts: tag_Environment_{{ env|replace('-', '_') }}:&tag_System_{{ system|replace('-', '_') }}:&tag_Subsystem_{{ subsystem|replace('-', '_') }}
  vars:
    var_file_path: "inventory/{{ env }}/group_vars/{{ env }}_{{ system }}_{{ subsystem }}.yml"
  tasks:
    - name: Check Var File
      stat: 
        path: "{{ var_file_path }}"
      delegate_to: localhost
      register: register_var_file
    - name: Load Var File
      include_vars: "{{ var_file_path }}"
      when: register_var_file.stat.exists
    - pause: prompt="Missing Vars for {{ env }}-{{ system }}-{{ subsystem }}\nPress enter to continue, Ctrl+C to interrupt"
      when: not register_var_file.stat.exists
```

We can then import this PB from our main playbook eg:

```yaml
---
- name: Var Loader for {{ env }}-{{ system }}-{{ subsystem }}
  import_playbook: var-loader.yml

- name: Do other stuff 1 for {{ env }}-{{ system }}-{{ subsystem }}
  hosts: tag_Environment_{{ env|replace('-', '_') }}:&tag_System_{{ system|replace('-', '_') }}:&tag_Subsystem_{{ subsystem|replace('-', '_') }}
  roles:
    - do-other-stuff-1

- name: Do other stuff 2 for {{ env }}-{{ system }}-{{ subsystem }}
  hosts: tag_Environment_{{ env|replace('-', '_') }}:&tag_System_{{ system|replace('-', '_') }}:&tag_Subsystem_{{ subsystem|replace('-', '_') }}
  roles:
    - do-other-stuff-2
```

## Often used modules and keywords

| Module/Keyword                                                                                                     | Description                                                                                              |
|--------------------------------------------------------------------------------------------------------------------|----------------------------------------------------------------------------------------------------------|
| [import_playbook](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/import_playbook_module.html) | Includes a file with a list of plays to be executed.                                                     |
| hosts (PB)                                                                                                         | A list of groups, hosts or host pattern that translates into a list of hosts that are the play’s target. |

## Ansible directory layout

The [top-level project directory layout](https://docs.ansible.com/ansible/2.8/user_guide/playbooks_best_practices.html#content-organization) is as follows:

```
inventories/
   production/
      hosts               # inventory file for production servers
      group_vars/
         group1.yml       # here we assign variables to particular groups
         group2.yml
      host_vars/
         hostname1.yml    # here we assign variables to particular systems
         hostname2.yml

   staging/
      hosts               # inventory file for staging environment
      group_vars/
         group1.yml       # here we assign variables to particular groups
         group2.yml
      host_vars/
         stagehost1.yml   # here we assign variables to particular systems
         stagehost2.yml

library/
module_utils/
filter_plugins/

site.yml
webservers.yml
dbservers.yml

roles/
    common/
    webtier/
    monitoring/
    fooapp/
```

## Examples

### list the inventory

```
ansible-inventory --graph -i ansible/inventory/aws_ec2.yml
@all:
  |--@aws_ec2:
  |  |--ec2-3-65-1-206.eu-central-1.compute.amazonaws.com
  |--@tag_Environment_dev:
  |  |--ec2-3-65-1-206.eu-central-1.compute.amazonaws.com
  |--@tag_Name_instance_a:
  |  |--ec2-3-65-1-206.eu-central-1.compute.amazonaws.com
  |--@tag_Subsystem_api:
  |  |--ec2-3-65-1-206.eu-central-1.compute.amazonaws.com
  |--@tag_System_web:
  |  |--ec2-3-65-1-206.eu-central-1.compute.amazonaws.com
  |--@ungrouped:
  
ansible all --list-hosts -i ansible/inventory/aws_ec2.yml
  hosts (1):
    ec2-3-65-1-206.eu-central-1.compute.amazonaws.com    
```

### ping the instances

```
cd /study-ansible/ansible
ansible all -m ping -i inventory/aws_ec2.yml -u ec2-user --private-key ../00-create-ec2/keypair
ec2-3-65-1-206.eu-central-1.compute.amazonaws.com | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3.7"
    },
    "changed": false,
    "ping": "pong"
}

# if we have an ansible.cfg configured, then we don't need the CLI options set of the inventory
ansible all -m ping -u ec2-user --private-key ../00-create-ec2/keypair
ec2-3-65-1-206.eu-central-1.compute.amazonaws.com | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3.7"
    },
    "changed": false,
    "ping": "pong",
    "warnings": [
        "Platform linux on host ec2-3-65-1-206.eu-central-1.compute.amazonaws.com is using the discovered Python interpreter at /usr/bin/python3.7, but future installation of another Python interpreter could change the meaning of that path. See https://docs.ansible.com/ansible-core/2.13/reference_appendices/interpreter_discovery.html for more information."
    ]
}

ansible-inventory --graph
@all:
  |--@aws_ec2:
  |  |--ec2-3-65-1-206.eu-central-1.compute.amazonaws.com
  |--@tag_Environment_dev:
  |  |--ec2-3-65-1-206.eu-central-1.compute.amazonaws.com
  |--@tag_Name_instance_a:
  |  |--ec2-3-65-1-206.eu-central-1.compute.amazonaws.com
  |--@tag_Subsystem_api:
  |  |--ec2-3-65-1-206.eu-central-1.compute.amazonaws.com
  |--@tag_System_web:
  |  |--ec2-3-65-1-206.eu-central-1.compute.amazonaws.com
  |--@ungrouped:
```

### playbooks

```
ansible-playbook ping-playbook.yml -u ec2-user --private-key ../00-create-ec2/keypair

# when there are no instances
ansible-playbook ping-playbook.yml -u ec2-user --private-key ../00-create-ec2/keypair
[WARNING]: provided hosts list is empty, only localhost is available. Note that the implicit localhost does not match 'all'
[WARNING]: Could not match supplied host pattern, ignoring: tag_Environment_dev
[WARNING]: Could not match supplied host pattern, ignoring: tag_System_web
[WARNING]: Could not match supplied host pattern, ignoring: tag_Subsystem_api

PLAY [My first play] *********************************************************************************************************************
skipping: no hosts matched

PLAY RECAP *******************************************************************************************************************************

# listing hosts only
ansible-playbook ping-playbook.yml -u ec2-user --private-key ../00-create-ec2/keypair --list-hosts

playbook: ping-playbook.yml

  play #1 (tag_Environment_dev:&tag_System_web:&tag_Subsystem_api): My first play	TAGS: []
    pattern: ['tag_Environment_dev:&tag_System_web:&tag_Subsystem_api']
    hosts (3):
      ec2-3-70-69-219.eu-central-1.compute.amazonaws.com
      ec2-18-196-128-76.eu-central-1.compute.amazonaws.com
      ec2-18-185-22-195.eu-central-1.compute.amazonaws.com
      
# list the tasks that would be executed
ansible-playbook ping-playbook.yml -u ec2-user --private-key ../00-create-ec2/keypair --list-tasks

playbook: ping-playbook.yml

  play #1 (tag_Environment_dev:&tag_System_web:&tag_Subsystem_api): My first play	TAGS: []
    tasks:
      Ping my hosts	TAGS: []
      Print message	TAGS: []
      Populate service facts	TAGS: []
      debug	TAGS: []
      Return listing to registered var	TAGS: []
      Print return information from the previous task	TAGS: []
      
# show program's version number, config file location, configured module search path, module location, executable location, etc
ansible-playbook --version
ansible-playbook [core 2.13.2]
  config file = /study-ansible/ansible/ansible.cfg
  configured module search path = ['/root/.ansible/plugins/modules', '/usr/share/ansible/plugins/modules']
  ansible python module location = /usr/local/lib/python3.10/site-packages/ansible
  ansible collection location = /root/.ansible/collections:/usr/share/ansible/collections
  executable location = /usr/local/bin/ansible-playbook
  python version = 3.10.5 (main, Jun  7 2022, 19:23:05) [GCC 11.2.1 20220219]
  jinja version = 3.1.2
  libyaml = False
```

## Configuration


