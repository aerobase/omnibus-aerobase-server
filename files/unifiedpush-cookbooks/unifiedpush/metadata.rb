name "unifiedpush"
maintainer "C-B4.com"
maintainer_email "support@C-B4.com"
license "Apache 2.0"
description "Install and configure Unifiedpush Server from Omnibus"
long_description "Install and configure Unifiedpush Server from Omnibus"
version "1.0.0"

recipe "unifiedpush", "Configures Unifiedpush Server from Omnibus"
recipe "unifiedpush-server", "Configures Unifiedpush Application Server from Omnibus"

supports 'centos'
supports 'redhat'
supports 'fedora'
supports 'debian'
supports 'ubuntu'

depends "runit"
depends "package"
