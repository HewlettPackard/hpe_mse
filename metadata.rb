name             'hpe_mse'
maintainer       'Hewlett Packard Entreprise CMS'
maintainer_email 'dominique.domet-de-mont@hpe.com'
license          'All Rights Reserved'
description      'HPE CMS MSE instance Installation and Configuration'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
chef_version     '>= 12.14' if respond_to?(:chef_version)

version          '0.4.3'

issues_url       'https://github.com/HewlettPackard/hpe_mse/issues'
source_url       'https://github.com/HewlettPackard/hpe_mse'
