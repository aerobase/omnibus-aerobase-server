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

# In order to prevent unecessary cache expiration,
# package and package version overrides, build_version
# and build_iteration are kept in <project-root>/omnibus_overrides.rb
overrides_path = File.expand_path("../../../omnibus_overrides.rb", __FILE__)
instance_eval(IO.read(overrides_path), overrides_path)
build_iteration IO.read(File.expand_path("../../../ITERATION", __FILE__)).strip

# Creates required build directories
dependency "preparation"

# ruby core tools, chef already include ruby, rubygems, bundler, ohai, appbundler ...
# ruby includes openssl, cacerts ...
dependency "config_guess"
dependency "chef"

# unifiedpush internal dependencies/components
dependency "aerobase"

#
# addons which require omnibus software defns (not direct deps of chef itself - RFC-063)
#
dependency "nokogiri" # (nokogiri cannot go in the Gemfile, see wall of text in the software defn)

# FIXME?: might make sense to move dependencies below into the omnibus-software chef
#  definition or into a chef-complete definition added to omnibus-software.
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

exclude "**/.git"
exclude "**/bundler/git"

package_user 'root'
package_group 'root'
