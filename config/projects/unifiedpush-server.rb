#
# Copyright 2015 YOUR NAME
#
# All Rights Reserved.
#

name "unifiedpush-server"
maintainer "Yaniv Marom-Nachumi"
homepage "https://c-b4.com"

# Defaults to C:/unifiedpush-server on Windows
# and /opt/unifiedpush-server on all other platforms
install_dir "#{default_root}/#{name}"

build_version Omnibus::BuildVersion.semver
build_iteration 1

# Creates required build directories
dependency "preparation"

# unifiedpush-server dependencies/components
dependency "postgresql"
dependency "nginx"
dependency "omnibus-ctl"

#dependency "chef"

# Version manifest file
dependency "version-manifest"

exclude "**/.git"
exclude "**/bundler/git"

