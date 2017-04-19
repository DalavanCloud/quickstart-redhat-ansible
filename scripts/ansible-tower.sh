#!/bin/bash -ex
# author tonynv@amazon.com
# Install Ansible Tower (version3)
#

USERDATAID=ansible_install
DATE=`date +%d-%m-%Y`


######################################################################
# Ec2 Metadata Variables
EC2_HOSTNAME=$(curl -s http://169.254.169.254/latest/meta-data/hostname)
EC2_PRIVATEIP=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)

######################################################################
#Source Files
######################################################################
ANSIBLE_SOURCE="https://releases.ansible.com/ansible-tower/setup-bundle"
ANSIBLE_SOURCE_FILE="ansible-tower-setup-bundle-latest.el7.tar.gz"

######################################################################
# Install Ansible Tower
######################################################################
echo "Installing Ansible Tower"
echo "Working in `pwd`"
curl -s ${ANSIBLE_SOURCE}/${ANSIBLE_SOURCE_FILE} -O

echo "Extract"
#Extract src_files
tar -zxvf ${ANSIBLE_SOURCE_FILE}

# Move into source dir
cd ansible-tower-setup*
echo "Moved to `pwd`"

# Setup ssh keys
ssh-keygen -t rsa -f ~/.ssh/id_rsa -q -N ""
cat ~/.ssh/id_rsa.pub   >>~/.ssh/authorized_keys
KNOWNHOSTS="0,$(ssh-keyscan  0.0.0.0 | grep 0.0.0.0)"
echo $KNOWNHOSTS >>~/.ssh/known_hosts 
KNOWNHOSTS="$EC2_PRIVATEIP,$(ssh-keyscan  0.0.0.0 | grep 0.0.0.0)"
echo $KNOWNHOSTS >>~/.ssh/known_hosts 

# Relax the min var requirements
sed -i -e "s/Defaults    requiretty/Defaults    \!requiretty/" /etc/sudoers

# Make file only readable by root
ADMINFO="/etc/qsadmin.conf"
chmod 400 ${ADMINFO}

##############################################################
# Pass Cloudformation Parms to Tower installer (then delete)
##############################################################
ANSIBLE_ADMIN_PASSWD=`cat $ADMINFO| grep ansible_admin_password | awk -F"|" '{print $2}'`
ANSIBLE_DBADMIN_PASSWD=`cat $ADMINFO| grep ansible_dbadmin_password | awk -F"|" '{print $2}'`

# Create inventory file
>inventory
cat <<EOF >> inventory
[tower]
${EC2_HOSTNAME}

[database]

[all:vars]
admin_password=${ANSIBLE_ADMIN_PASSWD} 

pg_host=''
pg_port=''

pg_database='awx'
pg_username='admin'
pg_password=${ANSIBLE_DBADMIN_PASSWD}

rabbitmq_port=5672
rabbitmq_vhost=tower
rabbitmq_username=tower
rabbitmq_password=${ANSIBLE_ADMIN_PASSWD}
rabbitmq_cookie=rabbitmqcookie

EOF

#############################################################
# Start Tower Setup
#############################################################
./setup.sh

# Remove files used in bootstraping
rm  $ADMINFO
echo "Finished Ansible Tower Bootstraping"