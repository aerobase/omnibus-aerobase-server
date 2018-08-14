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

name "mssql-jdbc"
default_version "6.4.0"
skip_transitive_dependency_licensing true

version "6.4.0" do
  source md5: "ea718ed07bdcb6f98814f11783df9fcb"
end

source url: "https://github.com/aerobase/mssql-jdbc/releases/download/v#{version}/sqljdbc_#{version}.0_enu.tar.gz"

relative_path "sqljdbc_#{version}.0_enu/sqljdbc_6.4/enu/auth/x64"

build do
  command "mkdir -p #{install_dir}/embedded/apps/mssql"
  sync "./", "#{install_dir}/embedded/apps/mssql"
end
