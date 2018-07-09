name 		     "aerobase"
maintainer 		 "Aerobase.org"
maintainer_email "support@aerobase.org"
license 		 "Apache 2.0"
description      "Install and configure Aerobase Server from Omnibus"
long_description "Install and configure Aerobase Server from Omnibus"
version 		 "1.2.0"

recipe "aerobase", "Configures Aerobase Server from Omnibus"
recipe "unifiedpush-server", "Configures Unifiedpush Application Server from Omnibus"
recipe "keycloak-server", "Configures KeyCloak Application Server from Omnibus"

%w{ ubuntu debian redhat centos oracle fedora windows }.each do |os|
  supports os
end

depends  'package'
depends  'enterprise'
depends  'java'

case node['platform']
when 'debian', 'ubuntu', 'redhat', 'centos', 'fedora'
  depends 'runit'
  depends 'apt'
  depends 'cassandra-dse'
when 'windows'
  depends 'windows'
end



