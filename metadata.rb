name 'hpe_mse'
maintainer 'Hewlett Packard Entreprise CMS'
maintainer_email 'dominique.domet-de-mont@hpe.com'
license 'All Rights Reserved'
description 'HPE CMS MSE instance Installation and Configuration'
long_description <<-EOH

= DESCRIPTION:
This book deploys an instance of HPE CMS Multimedia Services Environment (MSE) using Chef or Ansible scripts.
Such an instance consists in one or several nodes using ssh/scp as internodes communication.

Starting from a standard CentOS/RedHat distribution, this cookbook prepares the nodes 
for MSE deployment by configuring ssh, collecting the product distribution as ISO images,
installing and starting the automated deployer as Linux services, dropping the MSE descriptor 
on the MSE Element Manager (EMS) instance and eventually collecting the consolidated status 
on this same node.

Three recipes/roles: 
- base used for all nodes part of the MSE instance, 
- ems used for the node playing the MSE EMS role, in charge of receiving the MSE Descriptor, and collect the consolidated status of this MSE instance.
- collectInfo gathering deployment information from all nodes

The MSE Descriptor Assistant nivr-cluster-nfv.properties.html must be used to depict the MSE instance topology and build 
the .kitchen.yml/ansible.yml file used to deploy the MSE instance. This file embedds the MSE descriptor template,
dynamically turned to the actual MSE Descriptor at run time based on the instantiated nodes IP addresses and names.
Refer to the on-line help in this assistant for details on Ansible/Chef invocation.

Alternatively to Chef and Ansible scripts, this same assistant offers a deployment on a Kubernetes cluster of Docker containers.
Refer to the assistant on-line help for details.

= REQUIREMENTS:

CentOS/RedHat >= 6.3 on OpenStack, Azure or Amazon infrastructure

= ATTRIBUTES:

To keep the generated books generic, attributes are expected as environment variables for both the Infrastructure and Product definition:

# TAS product on CentOS 7
#########################
# URL providing MSE ISO images
export MSE_ISO_URL='ftp://mse4nfv:password@ftp.ext.hpe.com/chef/TAS31/'
# URL providing MSE patches
export MSE_PATCH_URL='ftp://mse4nfv:password@ftp.ext.hpe.com/chef/TAS31/'
# ISO image delivering the MSE automated deployer engine in MSE_ISO_URL or directory specified by cacheIso variable
export MSE_ENGINE='ClusterManager-3.1.6-3.000381.eab0051.el7.iso'
# List of ISO images delivering the MSE products in MSE_ISO_URL or directory specified by cacheIso variable
export MSE_PRODUCT="['TAS-3.1.1-9.020429.el7.iso','USPM433_Linux_RHEL7_4654.iso','HPE-Messaging-Gateway-3.1.1-1.000082.e4bc103.el7.iso','OpenCall-OCMP-4.5.0.iso','HPE-SNF-1.1.1-10.000589.el7.x86_64.iso']"
# List of lab drops as an array of rpm packages in MSE_ISO_URL or directory specified by cacheIso variable
export MSE_LABDROPS="['hpoc-nivr-nfv-3.1.8-3.000565.20190415184527.014d039.snap.el7.noarch.rpm','hpoc-nfv-base-1.1.8-2.000279.20190412103724.9a5e3eb.snap.el7.x86_64.rpm','hpoc-nfv-base-selinux-1.1.8-2.000279.20190412103724.9a5e3eb.snap.el7.x86_64.rpm']"
# URL providing common ssh keys: id_rsa, ssh_host_ecdsa_key, ssh_host_ed25519_key, ssh_host_rsa_key and their relative pub files
export MSE_SSH_KEYS_URL='ftp://mse4nfv:password@ftp.ext.hpe.com/chef/sshKeys/'
# Explicit additional packages to install if available: mlocate as a quick file searcher, omping as multicast checker
export YUM_EXPLICIT_PACKAGES="['mlocate','firewalld','iptables-services']"
# Mandatory services to be started
export MANDATORY_SERVICES="['firewalld']"
# Patched files as a dictionnary of files in MSE_PATCH_URL or variable cachePatch directory and their destination
export PATCHED_FILES='{"uspm-nfv-setup.sh": "/opt/OC/sbin/uspm-nfv-setup.sh"}'
# To force an OS signature as expected by demanding components like USPM, SEE
export CLOUD_OS_SIGNATURE="Red Hat Enterprise Linux Server release 7.4 (Maipo)"
# Optional YUM version lock file 
export YUM_VERSION_LOCK=''

# MSE product on CentOS 6
#########################
# URL providing MSE ISO images
export MSE_ISO_URL='ftp://mse4nfv:password@ftp.ext.hpe.com/chef/MSE30/'
# URL providing MSE patches
export MSE_PATCH_URL='ftp://mse4nfv:password@ftp.ext.hpe.com/chef/MSE30/'
# ISO image delivering the MSE automated deployer engine in MSE_ISO_URL or directory specified by cacheIso variable
export MSE_ENGINE='ClusterManager-3.1.6-1.000375.6e519a0.el6.iso'
# List of ISO images delivering the MSE products in MSE_ISO_URL or directory specified by cacheIso variable
export MSE_PRODUCT="['SEE-4.1.9-1.000223.a8b3309.el6.iso','MSE-3.0.7-1.000576.fc18d3a.el6.iso','simulap_internal_1.9.0-20180528105249git4e4f10f.iso','HPE-SMSC-2.1.1-01.1336.76ec5dc.snap.el6.x86_64.iso','OpenCall-OCMP-4.4.8.bg013842.el6.x86_64.iso','USPM4212_Linux_RHEL6_3931.iso','OpenCall_OCCP_3.0.3_004177.el6.x86_64.iso','HPE-TAS-Apps-1.1.1-001871.el6.iso']"
# List of lab drops as an array of rpm packages in MSE_ISO_URL or directory specified by cacheIso variable
export MSE_LABDROPS="['hpoc-nivr-nfv-3.1.8-4.000570.20190412142835.d98fa4a.snap.el6.noarch.rpm','hpoc-nivr-nfv-ocmp-3.1.8-4.000570.20190412142835.d98fa4a.snap.el6.noarch.rpm','hpoc-nfv-base-1.1.8-1.000277.20190412142924.8c5cbd6.snap.el6.x86_64.rpm','hpoc-nfv-base-selinux-1.1.8-1.000277.20190412142924.8c5cbd6.snap.el6.x86_64.rpm']"
# URL providing common ssh keys: id_rsa, ssh_host_ecdsa_key, ssh_host_ed25519_key, ssh_host_rsa_key and their relative pub files
export MSE_SSH_KEYS_URL='ftp://mse4nfv:password@ftp.ext.hpe.com/chef/sshKeys/'
# Explicit additional packages to install if available: mlocate as a quick file searcher, omping as multicast checker
export YUM_EXPLICIT_PACKAGES="['mlocate','omping','perl-Class-MethodMakerOcbu']"
# Mandatory services to be started
export MANDATORY_SERVICES="[]"
# Patched files as a dictionnary of files in MSE_PATCH_URL or variable cachePatch directory and their destination
export PATCHED_FILES='{"uspm-nfv-setup.sh": "/opt/OC/sbin/uspm-nfv-setup.sh"}'
# To force an OS signature as expected by demanding components like USPM, SEE
export CLOUD_OS_SIGNATURE='Red Hat Enterprise Linux Server release 6.9 (Santiago)'
# Optional YUM version lock file 
export YUM_VERSION_LOCK=''
# Optional list of YUM excluded packages
export YUM_EXCLUDE='xerces-c-3* perl-Class-MethodMaker-*'

# OpenStack Infrastructure
##########################
# Infrastructure credentials
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
export CLOUD_NAMESERVER="x.y.z.t"
# The OpenStack subnet connecting the instances
export CLOUD_SUBNET="devOps"
# Additional environment variables set in OpenStack instances as a json hash
export CLOUD_ENVIRONMENT='{"http_proxy": "http://x.y.z.t:port", "https_proxy": "http://x.y.z.t:port"}'
# The OpenStack image flavor used to instantiate the nodes
export CLOUD_FLAVOR="v4.m8"
# List of yum repositories to be used during MSE automated deployer installation
# labdrops is mandatory to enable the labdrops
export MSE_YUM_REPO='uspm,labdrops,base'
# URL delivering additional yum repositories definitions CLOUD_REPOS_LIST
export CLOUD_REPOS_URL="ftp://mse4nfv:password@ftp.ext.hpe.com/chef/repos/"
# The OpenStack image name and default user
# Cent OS 7
export CLOUD_IMAGE="Centos 7"
export CLOUD_DEFAULT_USER="centos"
# List of yum repositories definitions to add to the nodes retrieved from CLOUD_REPOS_URL
export CLOUD_REPOS_LIST="['uspm43.repo']"
# List of yum repositories to be used during MSE automated deployer installation
# RHEL 6
export CLOUD_IMAGE="CentOS 6"
export CLOUD_REPOS_LIST="['uspm42.repo']"
# Propagate user and key to ansible engine
export ANSIBLE_REMOTE_USER=$CLOUD_DEFAULT_USER
export ANSIBLE_PRIVATE_KEY_FILE=$CLOUD_SSH_KEY

# Static Infrastructure
##############
# The ssh public key used to reach the infrastructure
export CLOUD_SSH_KEY="../sshKeys/luna/id_rsa"
# Additional environment variables set in instances as a json hash
export CLOUD_ENVIRONMENT='{}'
# List of yum repositories to be used during MSE automated deployer installation
# labdrops is mandatory to enable the labdrops
export MSE_YUM_REPO='uspm,labdrops'
# The default user
export CLOUD_DEFAULT_USER="root"
# List of yum repositories definitions to add to the nodes retrieved from CLOUD_REPOS_URL
export CLOUD_REPOS_LIST="['uspm42RP7.private.repo','mysql.private.repo','mongodb.private.repo']"
export CLOUD_REPOS_URL="http://192.168.66.194/repos/"
# Propagate user and key to ansible engine
export ANSIBLE_REMOTE_USER=$CLOUD_DEFAULT_USER
export ANSIBLE_PRIVATE_KEY_FILE=$CLOUD_SSH_KEY

# Azure Infrastructure
######################
# The path to the ssh public key used to reach the infrastructure
export CLOUD_SSH_KEY="~/.ssh/id_rsa"
# Ansible only: the actual public key data
export CLOUD_SSH_KEY_PUBLIC_DATA="$(eval cat ${CLOUD_SSH_KEY}.pub)"
# The Azure location
export CLOUD_LOCATION="North Europe"
# The Azure distribution image
export CLOUD_DISTRO="centos"
# The Azure image flavor
export CLOUD_FLAVOR="Standard_D3"
# List of yum repositories to be used during MSE automated deployer installation
export MSE_YUM_REPO='labdrops,centos*,updates*,base*'
# Additional environment variables set in instances as a json hash
export CLOUD_ENVIRONMENT='{}'
# URL delivering additional yum repositories definitions CLOUD_REPOS_LIST
export CLOUD_REPOS_URL="ftp://mse4nfv:password@ftp.ext.hpe.com/chef/repos/"
# The default user
export CLOUD_DEFAULT_USER="azureuser"
# Ansible only: Propagate user and key to ansible engine
export ANSIBLE_REMOTE_USER=$CLOUD_DEFAULT_USER
export ANSIBLE_PRIVATE_KEY_FILE=$CLOUD_SSH_KEY
# Chef only: the subscription ID (duplicated from ~/.azure/credentials)
export AZURE_SUBSCRIPTION_ID="bfe94c07-338d-47cf-aded-e8015d247694"
# The image definition
export CLOUD_IMAGE_OFFER="CentOS"
export CLOUD_IMAGE_PUBLISHER="OpenLogic"
export CLOUD_IMAGE_VERSION="latest"
# Cent OS 7
export CLOUD_IMAGE_SKU="7.5"
export CLOUD_IMAGE="OpenLogic:CentOS:7.5:latest"
# List of yum repositories definitions to add to the nodes retrieved from CLOUD_REPOS_URL
export CLOUD_REPOS_LIST="['uspm43public.repo']"
# Cent OS 6
export CLOUD_IMAGE_SKU="6.9"
export CLOUD_REPOS_LIST="['uspm42public.repo']"
export CLOUD_IMAGE="OpenLogic:CentOS:6.9:latest"

# Amazon Infrastructure
#######################
# The ssh public key used to reach the infrastructure
export CLOUD_SSH_KEY="~/.aws/mse.pem"
# The ssh key pair used by resources in the infrastructure
export CLOUD_SSH_KEY_PAIR="mse"
# The Amazon security groups
export CLOUD_SECURITY_GROUPS="['sg-03527e0d7d4232a2f']"
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
# Additional environment variables set in instances as a json hash
export CLOUD_ENVIRONMENT='{}'
# List of yum repositories definitions to add to the nodes retrieved from CLOUD_REPOS_URL
export CLOUD_REPOS_LIST="['uspm43public.repo']"
export CLOUD_REPOS_URL="ftp://mse4nfv:password@ftp.ext.hpe.com/chef/repos/"
# Propagate user and key to ansible engine
export ANSIBLE_REMOTE_USER=$CLOUD_DEFAULT_USER
export ANSIBLE_PRIVATE_KEY_FILE=$CLOUD_SSH_KEY
# The Amazon image name
# Cent OS 7
export CLOUD_IMAGE="ami-3548444c"
# Cent OS 6
export CLOUD_IMAGE="ami-404f4339"

# (C) Copyright 2019 Hewlett Packard Enterprise Development LP.
EOH
version '0.4.4'
chef_version '>= 12.14' if respond_to?(:chef_version)

# The `issues_url` points to the location where issues for this cookbook are
# tracked.  A `View Issues` link will be displayed on this cookbook's page when
# uploaded to a Supermarket.
#
# issues_url 'https://github.com/HewlettPackard/hpe_mse/issues'

# The `source_url` points to the development repository for this cookbook.  A
# `View Source` link will be displayed on this cookbook's page when uploaded to
# a Supermarket.
#
# source_url 'https://github.com/HewlettPackard/hpe_mse'
