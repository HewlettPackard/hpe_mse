# DESCRIPTION
This book deploys an instance of HPE CMS Multimedia Services Environment (MSE) using Chef or Ansible scripts.
Such an instance consists of one or several nodes using SSH/SCP for inter-node communications.

Starting from a standard CentOS/RedHat distribution, this cookbook prepares the nodes 
for MSE deployment by configuring SSH, collecting the product distribution as ISO images,
installing and starting the automated deployer as Linux services, dropping the MSE descriptor 
on the MSE Element Manager (EMS) instance and eventually collecting the consolidated status 
on this same node.

Two recipes/roles: 
- base - used for all nodes part of the MSE instance, 
- ems - used for the node playing the MSE EMS role, in charge of receiving the MSE Descriptor, and collect the consolidated status of this MSE instance.

The MSE Descriptor Assistant `nivr-cluster-nfv.properties.html` must be used to describe the MSE instance topology and build 
the `.kitchen.yml/ansible.yml` file used to deploy the MSE instance. This file embedds the MSE descriptor template,
dynamically turned to the actual MSE Descriptor at run time based on the instantiated nodes IP addresses and names.

# REQUIREMENTS

CentOS/RedHat >= 6.3 on OpenStack, Azure or Amazon infrastructure

# ATTRIBUTES

To keep the generated books generic, attributes are expected as environment variables for both the Infrastructure and Product definition:

## TAS product on CentOS 7
-------------------------
```
# URL providing MSE ISO images
export MSE_ISO_URL='ftp://mse4nfv:password@ftp.ext.hpe.com/chef/TAS31/'
# ISO image delivering the MSE automated deployer engine
export MSE_ENGINE='ClusterManager-3.1.3-2.020130.el7.iso'
# List of ISO images delivering the MSE products
export MSE_PRODUCT="['TAS-3.1.1-6.020166.el7.iso','USPM433_Linux_RHEL7_4654.iso','HPE-Messaging-Gateway-3.1.0-1.019457.el7.iso']"
# List of lab drops as an array of rpm packages
export MSE_LABDROPS="['hpoc-nivr-nfv-3.1.3-3.020151.snap.1812211444.el7.noarch.rpm','hpoc-nivr-nfv-ocmp-3.1.3-3.020151.snap.1812211444.el7.noarch.rpm']"
# URL providing common ssh keys: id_rsa, ssh_host_ecdsa_key, ssh_host_ed25519_key, ssh_host_rsa_key and their relative pub files
export MSE_SSH_KEYS_URL='ftp://mse4nfv:password@ftp.ext.hpe.com/chef/sshKeys/'
# Explicit additional packages to install if available: mlocate as a quick file searcher, omping as mulitcast checker
export YUM_EXPLICIT_PACKAGES="['mlocate','omping','firewalld','iptables-services']"
# Mandatory services to be started
export MANDATORY_SERVICES="['firewalld']"
# Patched files as a dictionnary of files in MSE_ISO_URL or cache and their destination
export PATCHED_FILES='{"uspm-nfv-setup.sh": "/opt/OC/sbin/uspm-nfv-setup.sh"}'
# To force an OS signature as expected by demanding components like USPM, SEE
export CLOUD_OS_SIGNATURE="Red Hat Enterprise Linux Server release 7.4 (Maipo)"
# Optional YUM version lock file 
export YUM_VERSION_LOCK=''
```
## MSE product on CentOS 6
-------------------------
```
# URL providing MSE ISO images
export MSE_ISO_URL='ftp://mse4nfv:password@ftp.ext.hpe.com/chef/MSE30/'
# ISO image delivering the MSE automated deployer engine
export MSE_ENGINE='ClusterManager-3.1.3-2.020130.el6.iso'
# List of ISO images delivering the MSE products
export MSE_PRODUCT="['SEE-4.1.6.4-3.017751.el6.iso','MSE-3.0.5.3-8.020108.el6.iso','HPE-SMSC-2.1.0-1.000764.snap.el6.x86_64.iso','OpenCall-OCMP-4.4.8.bg013842.el6.x86_64.iso','USPM4212_Linux_RHEL6_3931.iso','OpenCall_OCCP_3.0.3_004177.el6.x86_64.iso']"
# List of lab drops as an array of rpm packages
export MSE_LABDROPS="['hpoc-nivr-nfv-3.1.3-3.020151.snap.1812201543.el6.noarch.rpm','hpoc-nivr-nfv-ocmp-3.1.3-3.020151.snap.1812201543.el6.noarch.rpm']"
# URL providing common ssh keys: id_rsa, ssh_host_ecdsa_key, ssh_host_ed25519_key, ssh_host_rsa_key and their relative pub files
export MSE_SSH_KEYS_URL='ftp://mse4nfv:password@ftp.ext.hpe.com/chef/sshKeys/'
# Explicit additional packages to install if available: mlocate as a quick file searcher, omping as mulitcast checker
export YUM_EXPLICIT_PACKAGES="['mlocate','omping','perl-Class-MethodMakerOcbu']"
# Mandatory services to be started
export MANDATORY_SERVICES="[]"
# Patched files as a dictionnary of files in MSE_ISO_URL or cache and their destination
export PATCHED_FILES='{"uspm-nfv-setup.sh": "/opt/OC/sbin/uspm-nfv-setup.sh"}'
# To force an OS signature as expected by demanding components like USPM, SEE
export CLOUD_OS_SIGNATURE='Red Hat Enterprise Linux Server release 6.9 (Santiago)'
# Optional YUM version lock file 
export YUM_VERSION_LOCK=''
# Optional list of YUM excluded packages
export YUM_EXCLUDE='xerces-c-3* perl-Class-MethodMaker-*'

```
## OpenStack Infrastructure
-------------------------
```# Infrastructure credentials
export OS_AUTH_URL="https://30.117.132.11:13000/v2.0"
export OS_PASSWORD="d3m"
export OS_PROJECT_ID="720fb530215e4113992367f2969d238f"
export OS_PROJECT_NAME="d3m"
export OS_USERNAME="d3m"
export OS_CACERT="grenoble-infra-root-ca_qhPfkrH.crt"
export NO_PROXY="127.0.0.1,30.114.132.5,gre.hpecorp.net"
# The ssh public key used to reach the infrastructure
export CLOUD_SSH_KEY="./d3m.pem"
# The ssh key pair used by resources within the infrastructure
export CLOUD_SSH_KEY_PAIR="d3m"
# The OpenStack security group
export CLOUD_SECURITY_GROUPS=default
# The OpenStack availability zone
export CLOUD_AVAILABILITY_ZONE="nova"
# The name server used by OpenStack instances
export CLOUD_NAMESERVER="16.110.135.52"
# The OpenStack subnet connecting the instances
export CLOUD_SUBNET="devOps"
# Additional environment variables set in OpenStack isntances as a json hash
export CLOUD_ENVIRONMENT='{"http_proxy": "http://x.y.z.t:port", "https_proxy": "http://x.y.z.t:port"}'
# The OpenStack image flavor used to instantiate the nodes
export CLOUD_FLAVOR="v4.m8"
# labdrops is mandatory to enable the labdrops
export MSE_YUM_REPO='uspm,labdrops,base'
# Cent OS 7
# The OpenStack image name and default user
export CLOUD_IMAGE="Centos 7"
export CLOUD_DEFAULT_USER="centos"
# List of yum repositories definitions to add to the nodes retrieved from CLOUD_REPOS_URL
export CLOUD_REPOS_LIST="['uspm43.repo']"
export CLOUD_REPOS_URL="ftp://mse4nfv:password@ftp.ext.hpe.com/chef/repos/"
# List of yum repositories to be used during MSE automated deployer installation
# RHEL 6
# The OpenStack image name and default user
export CLOUD_IMAGE="CentOS 6"
export CLOUD_REPOS_LIST="['uspm42.repo']"
# Propagate user and key to ansible engine
export ANSIBLE_REMOTE_USER=$CLOUD_DEFAULT_USER
export ANSIBLE_PRIVATE_KEY_FILE=$CLOUD_SSH_KEY

```
## Azure Infrastructure
-------------------------
```# The ssh public key used to reach the infrastructure
export CLOUD_SSH_KEY="~/.ssh/id_rsa"
# The Azure subscription ID and location
export AZURE_SUBSCRIPTION_ID="bfe94c07-338d-47cf-aded-e8015d247694"
export CLOUD_LOCATION="North Europe"
# The Azure distribution image
export CLOUD_DISTRO="centos"
# The Azure image flavor
export CLOUD_FLAVOR="Standard_D3"
# List of yum repositories to be used during MSE automated deployer installation
export MSE_YUM_REPO='labdrops,centos*,updates*,base*'
# Propagate user and key to ansible engine
export ANSIBLE_REMOTE_USER=$CLOUD_DEFAULT_USER
export ANSIBLE_PRIVATE_KEY_FILE=$CLOUD_SSH_KEY
# The Azure image name
# Cent OS 7
export CLOUD_IMAGE="OpenLogic:CentOS:7.4:latest"
# Cent OS 6
export CLOUD_IMAGE="OpenLogic:CentOS:6.9:latest"

```
## Amazon Infrastructure
```-------------------------
# The ssh public key used to reach the infrastructure
export CLOUD_SSH_KEY=~/.aws/mse.pem
# The ssh key pair used by resources in the infrastructure
export CLOUD_SSH_KEY_PAIR="mse"
# The Amazon security groups
export CLOUD_SECURITY_GROUPS=["sg-03527e0d7d4232a2f"]
# The Amazon availability zone
export CLOUD_AVAILABILITY_ZONE="b"
# The Amazon subnet
export CLOUD_SUBNET="subnet-bc1878f4"
# The Amazon location
export CLOUD_LOCATION="eu-west-1"
# The Amazon image flavor
export CLOUD_FLAVOR="t2.micro"
# List of yum repositories to be used during MSE automated deployer installation
export MSE_YUM_REPO='labdrops,centos*,updates*,base*'
export CLOUD_ENVIRONMENT='{}'
export CLOUD_REPOS_LIST="[]"
# Propagate user and key to ansible engine
export ANSIBLE_REMOTE_USER=$CLOUD_DEFAULT_USER
export ANSIBLE_PRIVATE_KEY_FILE=$CLOUD_SSH_KEY
# The Amazon image name
# Cent OS 7
export CLOUD_IMAGE="ami-3548444c"
# Cent OS 6
export CLOUD_IMAGE="ami-404f4339"
```
### (C) Copyright 2018 Hewlett Packard Enterprise Development LP.
