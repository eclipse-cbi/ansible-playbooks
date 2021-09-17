local ansible = import "inventory_utils/ansible.jsonnet";

{
  hosts: [
    ansible.newHost("b9h15", ansible.os.macos("10.15"), ansible.archs.x86_64, ansible.providers.macstadium, ["dedicated_agent", "eclipse.platform.releng"]),
    ansible.newHost("ta9y0", ansible.os.macos("10.15"), ansible.archs.x86_64, ansible.providers.macstadium, ["shared_agent", "eclipse.platform.releng"]),
    ansible.newHost("nc1ht", ansible.os.macos("11"), ansible.archs.arm64, ansible.providers.macstadium, ["dedicated_agent", "eclipse.platform.releng"]),
  ],
  inventory: ansible.inventory(self.hosts)
}