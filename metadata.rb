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
$env:AZURE_SSH_KEY="C:\Users\domin\.ssh\id_rsa"
# The Azure subscription ID and location
$env:AZURE_SUBSCRIPTION_ID="bfe94c07-338d-47cf-aded-e8015d247694"
$env:AZURE_LOCATION="North Europe"
# The Azure distribution image
$env:AZURE_DISTRO="centos"
$env:AZURE_IMAGE="OpenLogic:CentOS:7.4:latest"
# The Azure image flavor
$env:AZURE_FLAVOR="Standard_D3"

# MSE product
# URL providing MSE ISO images
$env:MSE_ISO_URL='http://orgues.free.fr/tmp/mse/'
# ISO image delivering the MSE automated deployer engine
$env:MSE_ENGINE='TAS-3.1.0-12.019538.el7.iso'
# List of ISO images delivering the MSE products
$env:MSE_PRODUCT="['P8070015.JPG','P8120023.JPG','P8120024.JPG']"
# List of yum repositories to be used for MSE automated deployer installation
$env:MSE_YUM_REPO='centos*,updates*,base*'
# URL providing common ssh keys: id_rsa, ssh_host_ecdsa_key, ssh_host_ed25519_key, ssh_host_rsa_key and their relative pub files
$env:MSE_SSH_KEYS_URL='http://orgues.free.fr/tmp/mse/' 

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
