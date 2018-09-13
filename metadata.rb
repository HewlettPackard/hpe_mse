name 'hpe_mse'
maintainer 'Hewlett Packard Entreprise CMS'
maintainer_email 'dominique.domet-de-mont@hpe.com'
license 'All Rights Reserved'
description 'HPE CMS MSE instance Installation and Configuration'
long_description <<-EOH

= DESCRIPTION:
This cookbook deploys an instance of 	HPE CMS Multimedia Services Environment (MSE).
Such an instance consists in one or several nodes using ssh/scp as internodes communication.

Starting from a standard CentOS/RedHat distribution, this cookbook prepares the nodes 
for MSE deployment by configuring ssh, collecting the product distribution as ISO images,
installing and starting the automated deployer as Linux services, dropping the MSE descriptor 
on the MSE Element Manager (EMS) instance and eventually collecting the consolidated status 
on this same node.

Two recipes: 
- base used for all nodes part of the MSE instance, 
- ems used for the node playing the MSE EMS role, in charge of receiving the MSE Descriptor, and collect the consolidated status of this MSE instance.

The MSE Descriptor Assistant nivr-cluster-nfv.html must be used to depict the MSE instance topology and build 
the .kitchen.yml file used to deploy the MSE instance. This file embedds the MSE descriptor template,
dynamically turned to the actual MSE Descriptor at run time based on the instantiated nodes IP addresses and names.

= REQUIREMENTS:

CentOS/RedHat >= 6.3 on Azure infrastructure

= ATTRIBUTES:

To keep the generated kitchen file generic, attributes are expected as environment variables for both the Infrastructure and Product:
# Infrastructure
# The ssh public key used by kitchen to reach the infrastructure
export AZURE_SSH_KEY="~/.ssh/id_rsa"
# The Azure subscription ID and location
export AZURE_SUBSCRIPTION_ID="bfe94c07-338d-47cf-aded-e8015d247694"
export AZURE_LOCATION="North Europe"
# The Azure distribution image
export AZURE_DISTRO="centos"
# The Azure image flavor
export AZURE_FLAVOR="Standard_D3"

# CentOS 7
#############
# MSE product
export AZURE_IMAGE="OpenLogic:CentOS:7.4:latest"
# URL providing MSE ISO images
export MSE_ISO_URL='ftp://mse4nfv:Blues.07@ftp.ext.hpe.com/chef/TAS31/'
# ISO image delivering the MSE automated deployer engine
export MSE_ENGINE='ClusterManager-3.1.1-2.019646.snap.el7.iso'
# List of ISO images delivering the MSE products
export MSE_PRODUCT="['TAS-3.1.1-1.019615.snap.el7.iso','USPM433_Linux_RHEL7_4654.iso','HPE-Messaging-Gateway-3.1.0-1.019457.el7.iso']"
# List of yum repositories to be used for MSE automated deployer installation
export MSE_YUM_REPO='centos*,updates*,base*'
# URL providing common ssh keys: id_rsa, ssh_host_ecdsa_key, ssh_host_ed25519_key, ssh_host_rsa_key and their relative pub files
export MSE_SSH_KEYS_URL='ftp://mse4nfv:Blues.07@ftp.ext.hpe.com/chef/sshKeys/'

# CentOS 6
#############
export AZURE_IMAGE="OpenLogic:CentOS:6.9:latest"
# MSE product
# URL providing MSE ISO images
export MSE_ISO_URL='ftp://mse4nfv:Blues.07@ftp.ext.hpe.com/chef/MSE30/'
# ISO image delivering the MSE automated deployer engine
export MSE_ENGINE='ClusterManager-3.1.1-2.019650.el6.iso'
# List of ISO images delivering the MSE products
export MSE_PRODUCT="['MSE-3.0.5.1-3.019636.el6.iso','SEE-4.1.6-4.017107.el6.iso','OpenCall-OCMP-4.4.8.bg013842.el6.x86_64.iso','USPM4212_Linux_RHEL6_3931.iso']"
# List of yum repositories to be used for MSE automated deployer installation
export MSE_YUM_REPO='centos*,updates*,base*'
# URL providing common ssh keys: id_rsa, ssh_host_ecdsa_key, ssh_host_ed25519_key, ssh_host_rsa_key and their relative pub files
export MSE_SSH_KEYS_URL='ftp://mse4nfv:Blues.07@ftp.ext.hpe.com/chef/sshKeys/'

EOH
version '0.1.0'
chef_version '>= 12.14' if respond_to?(:chef_version)

# The `issues_url` points to the location where issues for this cookbook are
# tracked.  A `View Issues` link will be displayed on this cookbook's page when
# uploaded to a Supermarket.
#
# issues_url 'https://github.com/<insert_org_here>/hpe_mse/issues'

# The `source_url` points to the development repository for this cookbook.  A
# `View Source` link will be displayed on this cookbook's page when uploaded to
# a Supermarket.
#
# source_url 'https://github.com/<insert_org_here>/hpe_mse'
