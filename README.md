# High Availability Setup Example

Work still in progress! Time spent: 13h 45m

### Whats going on?!

We'll implement high availability setup for a web app, so your site or even business always would be available for customers with 99.99% SLA* and zero downtime updates**

*According to [AWS SLA](https://aws.amazon.com/ru/compute/sla/)

**At least while you don't wanna do the sql database schema update

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

We would use some sensitive data that should never be stored in git repo, especially in public git repo  
Data like:
  - private aws ssh key
  - private ssh key for app deployment
  - mysql root password
  - mysql app password

Lucky that I already generated strongly passwords and keys for you and stored it in the encrypted vault :)  
You can store encrypted files like this in git repos with minimum risks

Vault file is `ansible/group_vars/all/vault.yml` and password is `my_vault_password`  
(don't use so weaked passwords like this at home)

So first of all, do this for preventing ansible asking vault password at each execution
```
cd ansible
echo 'my_vault_password' > .vault_pass
ansible-vault decrypt group_vars/all/vault.yml
```

Next step: terraform also require own variables, so we'll convert our ansible yaml file into terraform json
```
python -c 'import json, sys, yaml ; \
y=yaml.safe_load(open("group_vars/all/vault.yml").read()) ; \
open("../terraform/ansible.auto.tfvars", "w").write(json.dumps(y))'
```

And we also need aws ssh private key for applying ansible setup into hosts
```
python -c 'import json, sys, yaml ; \
y=yaml.safe_load(open("group_vars/all/vault.yml").read()) ; \
open("id_rsa_aws", "w").write(y["ssh_privkey"])'

chmod 600 id_rsa_aws
ssh-add id_rsa_aws
```

Finally close the vault file and change directory to the main
```
ansible-vault encrypt group_vars/all/vault.yml
cd ..
```

Now we are ready to go! :)

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

### What's next?

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