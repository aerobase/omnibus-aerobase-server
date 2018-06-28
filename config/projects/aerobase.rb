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
if windows?
  name "Aerobase"
else
  name "aerobase"
end 

package_name    "aerobase"
friendly_name   "Aerobase Platform"
maintainer "Aerobase Software, Inc. <maintainers@aerobase.io>"
homepage "https://aerobase.io"
license "Apache-2.0"
license_file "LICENSE"
install_dir     "#{default_root}/#{name}"

build_iteration 1
# Do not use __FILE__ after this point, use current_file. If you use __FILE__
# after this point, any dependent defs (ex: angrychef) that use instance_eval
# will fail to work correctly.
current_file ||= __FILE__
version_file = File.expand_path("../../../VERSION", current_file)
build_version IO.read(version_file).strip

# Creates required build directories
dependency "preparation"

if windows?
  dependency "postgresql-bin"
  dependency "nginx-bin"
else
  dependency "postgresql"
  dependency "nginx"
  dependency "logrotate"
  dependency "runit"
end

# unifiedpush dependencies/components
#dependency "omnibus-ctl"
#dependency "unifiedpush-ctl"
#dependency "chef"
#dependency "public_suffix"

# unifiedpush internal dependencies/components
# unifiedpush-server is the most expensive runtime build, therefore keep it first in order.
#dependency "unifiedpush-server"
#dependency "unifiedpush-admin-ui"
#dependency "aerobase-gsg-ui"
#dependency "aerobase-keycloak-theme"
#dependency "unifiedpush-config-template"
#dependency "unifiedpush-scripts"
#dependency "unifiedpush-cookbooks"

# Version manifest file
#dependency "version-manifest"

package :rpm do
  compression_level 6
  compression_type :xz
end

package :deb do
  compression_level 6
  compression_type :xz
end

msi_upgrade_code = "2CD7259C-776D-4DDB-A4C8-6E544E580AA1"
project_location_dir = name
package :msi do
  fast_msi true
  upgrade_code msi_upgrade_code
  wix_candle_extension "WixUtilExtension"
  wix_light_extension "WixUtilExtension"
  parameters ProjectLocationDir: project_location_dir
end

exclude "**/.git"
exclude "**/bundler/git"

package_user 'root'
package_group 'root'
