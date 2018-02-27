# Copyright:: Copyright (c) 2015.
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

name "unifiedpush-admin-ui"
default_version "master"

dependency "ruby"
dependency "bundler"
dependency "rsync"

source git: "https://github.com/aerobase/unifiedpush-admin-ui.git"

relative_path "unifiedpush-admin-ui"
build_dir = "#{project_dir}"

build do
  command "npm install"
  command "npm install -g bower"
  command "npm install -g grunt"
  command "npm install grunt-cli"
  command "bower update"
  command "grunt build" 

  # Copy resources
  command "mkdir -p #{install_dir}/embedded/apps/unifiedpush-server/unifiedpush-admin-ui/"
  command "#{install_dir}/embedded/bin/rsync --exclude='**/.git*' --delete -a ./dist/ #{install_dir}/embedded/apps/unifiedpush-server/unifiedpush-admin-ui/"
end
