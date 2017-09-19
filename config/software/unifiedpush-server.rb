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
default_version "SPRING_RX"

dependency "ruby"
dependency "bundler"
dependency "rsync"
dependency "postgresql"
dependency "wildfly"
dependency "cassandra-unit"

source git: "https://github.com/aerobase/unifiedpush-server.git"

relative_path "unifiedpush-server"
build_dir = "#{project_dir}"

build do
  command "mvn clean install -DskipTests"

  command "mkdir -p #{install_dir}/embedded/apps/unifiedpush-server/"

  # Strip version from packages.
  copy "#{project_dir}/servers/ups-wildfly/target/unifiedpush-server.war", "#{install_dir}/embedded/apps/unifiedpush-server/unifiedpush-server.war"
  copy "#{project_dir}/databases/initdb/target/unifiedpush-initdb.tar.gz", "#{install_dir}/embedded/apps/unifiedpush-server/unifiedpush-initdb.tar.gz"
  copy "#{project_dir}/keycloak-theme/target/unifiedpush-keycloak-theme.tar.gz", "#{install_dir}/embedded/apps/unifiedpush-server/unifiedpush-keycloak-theme.tar.gz"
  copy "#{project_dir}/admin-ui/target/unifiedpush-admin-ui.tar.gz", "#{install_dir}/embedded/apps/unifiedpush-server/unifiedpush-admin-ui.tar.gz"

  erb source: "version.yml.erb",
      dest: "#{install_dir}/embedded/apps/unifiedpush-server/version.yml",
      mode: 0644,
      vars: { default_version: default_version }
end

# extract initdb project to allow JPA based schema creation.
build do
  command "tar xzf #{install_dir}/embedded/apps/unifiedpush-server/unifiedpush-initdb.tar.gz -C #{install_dir}/embedded/apps/unifiedpush-server/"
end

