# High Availability Setup Example

Work still in progress! Time spent: 4h 10m

Stack:
  - AWS ec2 load balancer & instances, efs, rds
  - Docker containers and compose for running nginx + application
  - Terraform for configuring AWS infra
  - Ansible for configuring everything on the hosts

Out of scope:
  - Security: dns, ssl, access control including VPC and Basition host, waf
  - Infra: multisite setup, internal LB for app
  - Terraform: remote sync
  - Ansible: dynamic inventory
  - Dev env: docker registry, CD & CI env and system

How to do the same without AWS cloud:
  - Load Balancer:
      * you still can use some external lb like aws or cloudflare
      * or you should setup it yourself, maybe with keepalived and haproxy or nginx
  - Sync between hosts:
      * some sync script like lsync or syncthing
      * any cluster fs lile ceph or glusterfs
      * some ntfs like aws efs
  - Database:
      * you still can use some external db like aws rds
      * Mysql Galera
      * Mariadb master-master
    Anyway you should use keepalived or haproxy or glbd for HA for all except first one
  - Hosts: can be any :)