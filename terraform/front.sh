#!bin/bash

ansible-playbook -i "localhost," -c local ~/terraform-ansible/ansible/frontend.yml
