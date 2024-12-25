# terraform - docker

## Lab setup

- optimus
  - RHEL 9.5
  - terraform
- mycroft
  - Ubuntu LTS as 24.04
  - running docker
  - terraform access for user adam using ssh keys
  - usermod -aG kvm,libvirt,qemu adam
- network, same lan/subnet

## Notes

After cloning repo, initialize the working directory

> [adam@optimus docker]$ terraform init

terraform plan, check access and determine steps to meet desired state

> [adam@optimus docker]$ terraform plan

Which will give run down of what steps terraform is going to do

> --snip--\
> Terraform will perform the following actions:\
> \
>   \# docker_container.nginx will be created\
>   \+ resource "docker_container" "nginx" \{\
>       \+ attach                                      = false\
>       \+ bridge                                      = (known after apply)\
>       \+ command                                     = (known after apply)\
> --snip--

All looked good, so apply to create the docker containers
> [adam@optimus docker]$ terraform apply

if all ok should see message at end like "Apply complete! Resources: 2 added, 0 changed, 0 destroyed."

Should then see the docker images created
> adam@mycroft:~$ docker ps --all \
> CONTAINER ID   IMAGE          COMMAND                  CREATED          STATUS          PORTS                  NAMES \
> 3ebfbc4443e4   66f8bdd3810c   "\/docker-entrypoint.…"   52 seconds ago   Up 51 seconds   0.0.0.0:8002->80\/tcp   dlm-nginx2 \
> a0ea4a70d79a   66f8bdd3810c   "\/docker-entrypoint.…"   52 seconds ago   Up 51 seconds   0.0.0.0:8001->80\/tcp   dlm-nginx1

And can browse to it on http://mycroft:8001/ and http://mycroft:8002/

View the current state / plan
> [adam@optimus docker]$ terraform show

Clean up & get rid of docker images
> [adam@optimus docker]$ terraform destroy

## Errors to fix

[ ] TODO: destroy giving error about image still in use but does not appear to be

can see the image still present

> adam@mycroft:~$ docker images --all \
> REPOSITORY   TAG       IMAGE ID       CREATED       SIZE\
> nginx        latest    66f8bdd3810c   3 weeks ago   192MB

manually delete it

> adam@mycroft:~$ docker image rm 66f8bdd3810c

removes it ok but then terraform complains image is not present next apply

get image again and terraform apply works again

> adam@mycroft:~$ docker image pull nginx

## TODOs

[x] Terraform connect to mycroft\
[x] Terraform create multiple docker instances\
[ ] HA Proxy 443 with Cert to 8001/8002\
[ ] nginx docker both mount content /storage/www-content\
[ ] HA & nginx logs send somewhere useful\