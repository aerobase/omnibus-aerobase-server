#
# Copyright 2018 Aerobase
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

name "mscplus"
default_version "2013"
license :project_license

version "2013" do
  source md5: "840fd00248b026d49b82b18a577f862c"
end

source url: "https://github.com/aerobase/microsoft-c-redistributable/releases/download/#{version}/microsoft-c++-redistributable-#{version}_x64.tar.gz"

build do
  mkdir "#{install_dir}/embedded/apps/mscplus"
  copy "./vcredist_x64.exe", "#{install_dir}/embedded/apps/mscplus/vcredist_x64.exe"
end
