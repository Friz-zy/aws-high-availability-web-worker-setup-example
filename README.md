# High Availability Setup Example

Work still in progress! Time spent: 11h 35m

### Whats going on?!

Requirements:
  - [Terraform](http://terraform.io/)
  - [Ansible](https://www.ansible.com/)
  - [Existed AWS account with admin api credentials](https://docs.aws.amazon.com/en_us/general/latest/gr/aws-sec-cred-types.html#access-keys-and-secret-access-keys)
  - Understanding that applying this setup will cost you money for used aws resources
  - Understanding what we are doing here :)

Stack:
  - AWS ec2 load balancer & instances, efs, rds
  - Docker containers and compose for running nginx + application
  - Terraform for configuring AWS infra
  - Ansible for configuring everything on the hosts

Out of scope:
  - Security: ssl, access control including VPC and Basition host, waf
  - Infra: multisite setup, internal LB for app, dns
  - Terraform: remote backend
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

### Before we start :)

### Create infra with Terraform

```
cd terraform
terraform init
export AWS_ACCESS_KEY_ID="XXX"
export AWS_SECRET_ACCESS_KEY="YYY"
export AWS_DEFAULT_REGION="us-west-2"
terraform plan
terraform apply
```

### Setup services and configs with Ansible

```
cd ../ansible

```

### Don't forget to clean all in the end!

```
cd ../terraform
terraform destroy
cd ../
git reset --hard HEAD
```

### What next?

Tools:
* https://www.terraform.io
* https://aws.amazon.com/ru/blogs/apn/terraform-beyond-the-basics-with-aws/
* https://github.com/leucos/ansible-tuto
* https://docs.docker.com/compose/

Understanding:
* https://hackernoon.com/the-2018-devops-roadmap-31588d8670cb
* https://www.digitalocean.com/community/tutorials/what-is-high-availability
* https://12factor.net/
* https://landing.google.com/sre/books/