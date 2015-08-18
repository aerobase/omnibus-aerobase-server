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

require "#{Omnibus::Config.project_root}/lib/unifiedpush/build_iteration"

name "unifiedpush-server"
maintainer "Yaniv Marom-Nachumi"
homepage "https://github.com/C-B4/omnibus-unifiedpush-server"

# Defaults to C:/unifiedpush on Windows
# and /opt/unifiedpush on all other platforms
install_dir "#{default_root}/unifiedpush"

build_version   Omnibus::BuildVersion.new.semver
build_iteration Unifiedpush::BuildIteration.new.build_iteration

# Creates required build directories
dependency "preparation"

# unifiedpush dependencies/components
dependency "postgresql"
dependency "nginx"
dependency "omnibus-ctl"
dependency "chef"
dependency "runit"

# unifiedpush internal dependencies/components
dependency "unifiedpush-ctl"
dependency "unifiedpush-config-template"
dependency "unifiedpush-scripts"
dependency "unifiedpush-cookbooks"
dependency "unifiedpush-package-scripts"
dependency "unifiedpush-server"

# Version manifest file
dependency "version-manifest"

exclude "**/.git"
exclude "**/bundler/git"

