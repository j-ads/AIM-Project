#!bin/bash

#Create and save the keys
cd terraform 
mkdir keys
cd keys
ssh-keygen -b 2048 -t rsa -f publickey -q -N "" && ssh-keygen -b 2048 -t rsa -f privatekey -q -N ""
ssh-add publickey && ssh-add privatekey

#run ansible playbook
cd ../../
ansible-playbook create-staging.yml

