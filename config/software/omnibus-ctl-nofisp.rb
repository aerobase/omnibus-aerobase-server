# Copyright:: Copyright (c) 2012 Opscode, Inc.
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# Cancel fisp check for any omnibus-ctl (chef-client) command
# https://aerobase.atlassian.net/browse/AEROBASE-131

name "omnibus-ctl-nofisp"
default_version "1.0.0"

dependency "omnibus-ctl"

license :project_license

build do
  if windows?
    ruby "-pi.bk -e \"gsub(/chef-client/, 'chef-client --no-fips')\" #{install_dir}/embedded/lib/ruby/gems/3.0.0/gems/omnibus-ctl-0.6.0/lib/omnibus-ctl.rb"
  end
end
