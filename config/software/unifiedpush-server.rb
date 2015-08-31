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
  command "mvn -T #{workers} clean install"

  command "mkdir -p #{install_dir}/embedded/apps/unifiedpush"

  copy "#{project_dir}/servers/ups-wildfly/target/unifiedpush-server.war",      "#{install_dir}/embedded/apps/unifiedpush/unifiedpush-server.war"
  copy "#{project_dir}/servers/auth-server/target/auth-server.war",  "#{install_dir}/embedded/apps/unifiedpush/auth-server.war"

  erb source: "version.yml.erb",
      dest: "#{install_dir}/embedded/apps/unifiedpush/version.yml",
      mode: 0644,
      vars: { default_version: default_version }
end

# Build initdb project to allow JPA based schema creation.
build do
  command "mvn -T #{workers} clean install -f databases/initdb/pom.xml"
  command "tar xzf #{project_dir}/databases/initdb/target/unifiedpush-initdb.tar.gz --strip-components 1 -C #{install_dir}/embedded/apps/unifiedpush/"
end