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

name "postgresql-bin"
default_version "9.6.9-1"

version "9.6.9-1" do
  source md5: "a3bc0afea4f31ec27ebf2ed4a80c9476"
end

source url: "https://get.enterprisedb.com/postgresql/postgresql-#{version}-windows-x64-binaries.zip"

relative_path "pgsql"
build_dir = "#{project_dir}"

build do
  copy "./bin", "#{install_dir}/embedded"
  copy "./lib", "#{install_dir}/embedded"
  copy "./include", "#{install_dir}/embedded"
  copy "./symbols", "#{install_dir}/embedded"
  copy "./share", "#{install_dir}/embedded"
end
