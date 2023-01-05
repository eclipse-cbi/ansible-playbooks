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
    ansible-playbook -i inventory.sh --extra-vars "@local-config.yml" site.yml
    ```

### Requirements

* [ansible](https://github.com/ansible/ansible/) (2.11+)
* [bash 4](https://www.gnu.org/software/bash/)
* expect
* [jsonnet](https://github.com/google/jsonnet/)
* [jq](https://stedolan.github.io/jq/)
* [pass](https://www.passwordstore.org) (gnupg)
* [ssh](https://www.openssh.com/)

## Provision a new mac

* Create a new agent at MacStadium (with according spec).
* Change the name in the MacStadium UI to `$(pwgen -s -A -1 5)-macos${MACOS_VERSION}-${CPU_ARCH}`, where `MACOS_VERSION` is the release version of macOS installed on the machine (e.g., `10.15`, `12`, ...) and `CPU_ARCH` is the CPU architecture (e.g., `x86_64`, `arm64`, ...).
  * This name will be referred to as `${AGENT_NAME}` from now on.
* Log into the machine via the credentials sent by MacStadium
* Generate a new password for `administrator` and put it into IT's pass
  * `pass insert -m IT/CBI/agents/macstadium/${AGENT_NAME}/users/administrator/password <<<$(pwgen -s -y -1 28)`
* Insert the agent IP in IT's pass
  * pass insert `IT/CBI/agents/macstadium/${AGENT_NAME}/ip`
* Change `administrator`'s password on remote machine to the new generated one. It will ask for previous password (the one set by Macstadium)
  * `passwd`
  * `security set-keychain-password`
* Generate a new ssh key for administrator and put it in IT's pass with a strong passphrase
  * `pass insert "IT/CBI/agents/macstadium/${AGENT_NAME}/users/administrator/id_rsa.passphrase" <<<$(pwgen -s -a 64 -1)`
  * `ssh-keygen -t rsa -b 4096 -C '' -f /tmp/id_rsa`
  * `pass insert -m "IT/CBI/agents/macstadium/${AGENT_NAME}/users/administrator/id_rsa" </tmp/id_rsa`
  * `pass insert -m "IT/CBI/agents/macstadium/${AGENT_NAME}/users/administrator/id_rsa.pub" </tmp/id_rsa.pub`
* Deploy the key to the remote host
  * `ssh-copy-id -o IdentitiesOnly=yes -i /tmp/id_rsa  administrator@<IP>`
  * `rm -f /tmp/id_rsa*`
* Log into a desktop session on the remote mac as administrator
  * Open a terminal and run the command `xcode-select --install`
  * It may be already there, in this case, profit :)
* Add the agent to the inventory and create the associated playbooks as [documented](DOCUMENTATION.md).


* Create credentials for the projects in CBI's pass
  * `pass bots/${PROJECT_FULLNAME}/agents/macstadium/${AGENT_NAME}/password`
  * A ssh keyset for the agent's user