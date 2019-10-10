#
# Copyright:: Copyright (c) 2015.
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

name "mariadb-jdbc"
default_version "2.4.4"
skip_transitive_dependency_licensing true

version "2.4.4" do
  source md5: "22330c5b473ac23ba71285c6451da4cc"
end

source url: "https://downloads.mariadb.com/Connectors/java/connector-java-#{version}/mariadb-java-client-#{version}.jar"

build do
  command "mkdir -p #{install_dir}/embedded/apps/mariadb"
  copy "./mariadb-java-client-#{version}.jar", "#{install_dir}/embedded/apps/mariadb"
  
end
