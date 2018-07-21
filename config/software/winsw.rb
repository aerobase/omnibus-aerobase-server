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

name "winsw"
default_version "2.1.2"
skip_transitive_dependency_licensing true

version "2.1.2" do
  source md5: "1f41775fcf14aee2085c5fca5cd99d81"
end

source url: "https://github.com/kohsuke/winsw/releases/download/winsw-v#{version}/WinSW.NET4.exe"

relative_path "winsw"

build do
  env = with_standard_compiler_flags

  command "mkdir -p #{install_dir}/embedded/apps/winsw"
  copy "./WinSW.NET4.exe", "#{install_dir}/embedded/apps/winsw/aerobasesw.exe"
end
