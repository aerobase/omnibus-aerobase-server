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
# Aerobase patches are packed alongside with keycloak dist
# Included pathces: KEYCLOAK-6225
# Every KC Update, require evaluation rather PRs accepted by KC.
 
name "aerobase-keycloak-patch"
default_version "11.0.3"
skip_transitive_dependency_licensing true

source git: "https://github.com/aerobase/keycloak.git"

relative_path "aerobase-keycloak-patch"
build_dir = "#{project_dir}"

build do
  command "mvn install -DskipTests"

    # Copy dist to package dir.
  command "mkdir -p #{install_dir}/embedded/apps/aerobase-keycloak-patch/keycloak-kerberos-federation"
  command "mkdir -p #{install_dir}/embedded/apps/aerobase-keycloak-patch/keycloak-services"
  command "mkdir -p #{install_dir}/embedded/apps/aerobase-keycloak-patch/keycloak-server-spi"
  command "mkdir -p #{install_dir}/embedded/apps/aerobase-keycloak-patch/keycloak-ldap-federation"
  
  copy "./federation/kerberos/target/keycloak-kerberos-federation-#{default_version}.jar", "#{install_dir}/embedded/apps/aerobase-keycloak-patch/keycloak-kerberos-federation"
  copy "./services/target/keycloak-services-#{default_version}.jar", "#{install_dir}/embedded/apps/aerobase-keycloak-patch/keycloak-services"
  copy "./server-spi/target/keycloak-server-spi-#{default_version}.jar", "#{install_dir}/embedded/apps/aerobase-keycloak-patch/keycloak-server-spi"
  copy "./federation/ldap/target/keycloak-ldap-federation-#{default_version}.jar", "#{install_dir}/embedded/apps/aerobase-keycloak-patch/keycloak-ldap-federation"
end
