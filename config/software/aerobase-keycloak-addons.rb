# Copyright:: Copyright (c) 2018, Aerobase Inc.
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

name "aerobase-keycloak-addons"
default_version "17.0.1"
skip_transitive_dependency_licensing true

source git: "https://github.com/aerobase/keycloak-extension-playground.git"

relative_path "keycloak-extension-playground"
build_dir = "#{project_dir}"

build do
  command "mvn clean install -DskipTests -N"
  command "mvn clean install -DskipTests -Djava.version=8 -Dkeycloak.version=17.0.0 -f auth-require-group-extension/pom.xml"
  command "mvn clean install -DskipTests -Djava.version=8 -Dkeycloak.version=17.0.0 -f auth-require-role-extension/pom.xml"

  # Copy dist to package dir.
  command "mkdir -p #{install_dir}/embedded/apps/aerobase-keycloak-addons"
  copy "./auth-require-group-extension/target/auth-require-group-extension-#{default_version}.jar", "#{install_dir}/embedded/apps/aerobase-keycloak-addons"
  copy "./auth-require-role-extension/target/auth-require-role-extension-#{default_version}.jar", "#{install_dir}/embedded/apps/aerobase-keycloak-addons"
end
