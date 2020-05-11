name             'seven_zip'
maintainer       'Shawn Neal'
maintainer_email 'sneal@sneal.net'
source_url       'https://github.com/windowschefcookbooks/seven_zip'
issues_url       'https://github.com/windowschefcookbooks/seven_zip/issues'
chef_version     '>= 13.0' if respond_to?(:chef_version)
license          'Apache-2.0'
description      'Installs/Configures 7-Zip'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '3.1.2'
supports         'windows'
depends          'windows'
