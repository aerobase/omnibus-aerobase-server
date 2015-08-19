#
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

name "unifiedpush-server"
default_version "1.1.0-beta.4" # 2.1.0.Final

dependency "ruby"
dependency "bundler"
dependency "rsync"
dependency "postgresql"
dependency "wildfly"

source :git => "https://github.com/C-B4/unifiedpush-server.git"

relative_path "unifiedpush-server"
build_dir = "#{project_dir}"

build do
  env = with_standard_compiler_flags(with_embedded_path)

  command "mvn -T #{workers} clean install"

  command "mkdir -p #{install_dir}/embedded/apps/unifiedpush-server"

  copy "#{project_dir}/servers/ups-wildfly/target/ag-push.war",      "#{install_dir}/embedded/apps/unifiedpush-server/unifiedpush-server.war"
  copy "#{project_dir}/servers/auth-server/target/auth-server.war",  "#{install_dir}/embedded/apps/unifiedpush-server/auth-server.war"

  erb source: "version.yml.erb",
      dest: "#{install_dir}/embedded/apps/unifiedpush-server/version.yml",
      mode: 0644,
      vars: { default_version: default_version }
end
