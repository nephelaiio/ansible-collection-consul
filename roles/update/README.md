# nephelaiio.consul.update

An Ansible role to safely update Consul cluster nodes by performing OS package updates and coordinated reboots while maintaining cluster integrity.

## Description

This role provides a safe mechanism to update Consul cluster nodes by:

- Stopping the Consul service
- Updating OS packages using the `nephelaiio.consul.os_update` role
- Performing a controlled reboot
- Verifying the node rejoins the cluster successfully

The role ensures cluster stability by validating that the updated node returns to an "alive" state and maintains its expected role (server) in the cluster.

## Role Variables

Available variables are listed below, along with default values (see `defaults/main.yml`):

```yaml
# Timeout for node reboot operation (seconds)
consul_upgrade_reboot_timeout: 300

# Number of retries for cluster status verification
consul_upgrade_task_retries: 10

# Delay between retries for cluster status verification (seconds)
consul_upgrade_task_delay: 10
```

## Invocation

```bash
   ansible-playbook nephelaiio.consul.update -i inventory/
```

Update process will be performed one node at a time to maintain cluster quorum. The role will reboot the target node as part of the update process

## License

MIT

## Author Information

This role was created by [nephelaiio](https://github.com/nephelaiio).
