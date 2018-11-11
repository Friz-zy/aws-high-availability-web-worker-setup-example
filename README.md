# High Availability Setup Example

Work still in progress! 
Time spent: 2h 30m


Stack:
  - AWS ec2 load balancer & instances, efs, rds
  - Docker containers and compose for running nginx + application
  - Terraform for configuring AWS infra
  - Ansible for configuring everything on the hosts

Out of scope:
  - Security: dns, ssl, access control including VPC and Basition host, waf
  - Terraform: remote sync
  - Ansible: dynamic inventory

How to do the same without AWS cloud:
  - Load Balancer:
      * you still can use some external lb like aws or cloudflare
      * or you should setup it yourself, maybe with keepalived and haproxy or nginx
  - Sync between hosts:
      * some sync script like lsync or syncthing
      * any cluster fs lile ceph or glusterfs
      * some ntfs like aws efs
  - Database:
      * Mysql Galera
      * Mariadb master-master
    Anyway you should use keepalived or haproxy or glbd for HA
  - Hosts: can be any :)