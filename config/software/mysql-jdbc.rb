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

name "mysql-jdbc"
default_version "8.0.17"
skip_transitive_dependency_licensing true

version "8.0.17" do
  source md5: "f4a7b4ca814488d15a73f71a93df3f9c"
end

source url: "https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-8.0.17.tar.gz"

relative_path "mysql-connector-java-8.0.17"

build do
  command "mkdir -p #{install_dir}/embedded/apps/mysql"
  copy "./mysql-connector-java-8.0.17.jar", "#{install_dir}/embedded/apps/mysql"
  
end
