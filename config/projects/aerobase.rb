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
  install_dir  "#{default_root}/Aerobase/#{name}"
else
  name "aerobase"
  install_dir  "#{default_root}/#{name}"
end 

package_name    "aerobase"
friendly_name   "Aerobase Platform"
maintainer "Aerobase Software, Inc. <maintainers@aerobase.io>"
homepage "https://aerobase.io"
license "Apache-2.0"
license_file "LICENSE"
build_version IO.read(File.expand_path("../../../VERSION", __FILE__)).strip
build_iteration 1

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
dependency "omnibus-ctl"
dependency "chef"
dependency "public_suffix"

# unifiedpush internal dependencies/components
dependency "aerobase"

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