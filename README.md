# Ansible Playbook for CBI

## Description

This is a set of playbooks for machines (including Jenkins dedicated agents) managed by the CBI project.

## Documentation

The main playbook for all hosts is `site.yml` and it is including other playbooks that are more host specifics.

### How to run playbook?

1. Create a local-config.yml file with proper settings. See `local-config.sample.yml` for what needs to be set.

2. An ssh-agent should run before calling the playbooks. An utility script is included. Just like `ssh-agent` binary, you need to eval the output in your current shell to properly export environment variables. Whereas `ssh-agent` spawn a new agent every single time it is called, this utility script will cache the info about the spawned ssh-agent in `${HOME}/.ssh-agent` and will reuse it when it is legit to do so.

    ```bash
    eval "$(./ssh-agent.sh)"
    ```

3. Install requirements

    ```bash
    ansible-galaxy install -r requirements.yml
    ```

    `--force` may be required

4. Execute playbook with proper inventory

    ```bash
    ansible-playbook -i inventory.sh --extra-vars "@local-config.yml" cbi-dedicated-agents.yml
    ```

### Requirements

* ssh
* ansible (2.11+)
* jsonnet
* jq
* expect
* pass (gnupg)
