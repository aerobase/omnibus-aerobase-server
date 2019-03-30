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

name "aerobase-keycloak-spi"
default_version "v2.2.3"
skip_transitive_dependency_licensing true

source git: "https://github.com/aerobase/aerobase-keycloak-spi.git"

relative_path "aerobase-keycloak-spi"
build_dir = "#{project_dir}"

build do
  command "mvn clean install -DskipTests"

    # Copy dist to package dir.
  command "mkdir -p #{install_dir}/embedded/apps/aerobase-keycloak-spi"
  copy "./target/aerobase-keycloak-spi.jar", "#{install_dir}/embedded/apps/aerobase-keycloak-spi"
end
