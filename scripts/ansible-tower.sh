#!/bin/bash -ex
# author tonynv@amazon.com
# Install Ansible Tower
#

USERDATAID=ansible_install
QS_DEPLOY_ROOT=/root
DATE=`date +%d-%m-%Y`

######################################################################
#Source Files
######################################################################
ANSIBLE_SOURCE="https://releases.ansible.com/ansible-tower/setup-bundle"
ANSIBLE_SOURCE_FILE="ansible-tower-setup-bundle-latest.el7.tar.gz"

