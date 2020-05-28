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

name "postgresql-jdbc"
default_version "42.2.12"
skip_transitive_dependency_licensing true

version "42.2.12" do
  source md5: "f8d55c8180c54ce6c713025faf459fd5"
end

source url: "https://jdbc.postgresql.org/download/postgresql-#{version}.jar"

build do
  command "mkdir -p #{install_dir}/embedded/apps/postgresql"
  sync "./", "#{install_dir}/embedded/apps/postgresql"
end
