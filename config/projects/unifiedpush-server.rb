#
# Copyright:: Copyright (c) 2013, 2014
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require "#{Omnibus::Config.project_root}/lib/unifiedpush-server/build_iteration"

name "unifiedpush-server"
maintainer "Yaniv Marom-Nachumi"
homepage "https://github.com/C-B4/omnibus-unifiedpush-server"

# Defaults to C:/unifiedpush-server on Windows
# and /opt/unifiedpush-server on all other platforms
install_dir "#{default_root}/#{name}"

build_version Omnibus::BuildVersion.semver
build_iteration Unifiedpush::BuildIteration.new.build_iteration

# Creates required build directories
dependency "preparation"

# unifiedpush-server dependencies/components
dependency "postgresql"
dependency "nginx"
dependency "omnibus-ctl"
dependency "chef"

# unifiedpush-server internal dependencies/components
dependency "unifiedpush-server-ctl"
dependency "unifiedpush-server-config-template"
dependency "unifiedpush-server-scripts"

# Version manifest file
dependency "version-manifest"

exclude "**/.git"
exclude "**/bundler/git"

