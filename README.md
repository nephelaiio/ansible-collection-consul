# Ansible Collection - pokerops.consul

[![Build Status](https://github.com/pokerops/ansible-collection-consul/actions/workflows/molecule.yml/badge.svg)](https://github.com/pokerops/ansible-collection-consul/actions/wofklows/molecule.yml)
[![Ansible Galaxy](http://img.shields.io/badge/ansible--galaxy-pokerops.consul-blue.svg)](https://galaxy.ansible.com/ui/repo/published/pokerops/consul/)

An [ansible collection](https://galaxy.ansible.com/ui/repo/published/pokerops/consul/) to install and manage [Consul](https://www.consul.io/) clusters

## ToDo

* Add CI harness
* Add role dependencies
* Add install playbook
* Add install CI tests
* Add update playbook
* Add update CI tests
* Publish collection

## Collection hostgroups

| Hostgroup    | Default | Description    |
|:-------------|--------:|:---------------|
| consul_group | consul' | Consul cluster |
|              |         |                |

## Collection variables

The following is the list of parameters intended for end-user manipulation: 

Cluster wide parameters

| Parameter               |                         Default | Description                            | Required |
|:------------------------|--------------------------------:|:---------------------------------------|:---------|
| consul_release          |                        1.18.1-1 | Consul release target                  | false    |
| consul_datacenter_name  |                        'consul' | Consul Datacenter name                 | false    |
| consul_backup_path      |               '/backups/consul' | Consul snapshot backup path            | false    |
| consul_backup_bin       | '/usr/local/bin/consul-snapshot | Consul snapshot backup script location | false    |
| consul_backup_retention |                            1440 | Consul snapshot retention in minutes   | false    |
| consul_backup_minutes   |                          '\*/5' | Consul snapshot cronjob component      | false    |
| consul_backup_hours     |                            '\*' | Consul snapshot cronjob component      | false    |
| consul_backup_days      |                            '\*' | Consul snapshot cronjob component      | false    |

## Collection playbooks

* pokerops.consul.install: Install and bootstrap cluster
* pokerops.consul.update: Install and bootstrap cluster

## Testing

Please make sure your environment has [docker](https://www.docker.com) installed in order to run role validation tests.

Role is tested against the following distributions (docker images):

  * Ubuntu Jammy
  * Debian 12
  * Rocky Linux 9

You can test the collection directly from sources using command `make test`

## License

This project is licensed under the terms of the [MIT License](/LICENSE)

