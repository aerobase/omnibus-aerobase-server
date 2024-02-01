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
package_name    "aerobase-openjdk"
friendly_name   "Aerobase Platform"
maintainer "Aerobase Software, Inc. <maintainers@aerobase.io>"
homepage "https://aerobase.io"
license "Apache-2.0"
license_file "LICENSE"

# Do not use __FILE__ after this point, use current_file. If you use __FILE__
# after this point, any dependent defs (ex: angrychef) that use instance_eval
# will fail to work correctly.
current_file ||= __FILE__

build_version IO.read(File.expand_path("../../../VERSION", current_file)).strip
build_iteration IO.read(File.expand_path("../../../ITERATION", current_file)).strip

if windows?
  name "Aerobase"
  install_dir  "#{default_root}/Aerobase/#{name}"
else
  name "aerobase"
  install_dir  "#{default_root}/#{name}"
end 

# Load dynamically updated overrides
overrides_path = File.expand_path("../../../omnibus_overrides.rb", current_file)
instance_eval(IO.read(overrides_path), overrides_path)

# Creates required build directories
dependency "preparation"

# ruby core tools, chef already include ruby, rubygems, bundler, ohai, appbundler ...
# ruby includes openssl, cacerts ...
dependency "chef"

# unifiedpush internal dependencies/components
dependency "aerobase"
dependency "openjdk"
# Must be after aerobase deps to prevent errors
dependency "omnibus-ctl-nofisp"
dependency "gem-permissions"
dependency "version-manifest"
dependency "openssl-customization"
dependency "shebang-cleanup"
dependency "ruby-cleanup"

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

# We don't support appx builds, and they eat a lot of time.
package :appx do
  skip_packager true
end

exclude "**/.git"
exclude "**/bundler/git"

package_user 'root'
package_group 'root'
