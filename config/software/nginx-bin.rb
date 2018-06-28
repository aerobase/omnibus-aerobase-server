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

name "nginx-bin"
default_version "1.14.0"

version "1.14.0" do
  source md5: "c645cfcd1c74416c7741fd17ce616523"
end

source url: "http://nginx.org/download/nginx-#{version}.zip"

relative_path "nginx-#{version}"
build_dir = "#{project_dir}"

build do
  mkdir "#{install_dir}/embedded/bin"
  mkdir "#{install_dir}/embedded/lib"
  mkdir "#{install_dir}/embedded/include"

  sync "./", "#{install_dir}/nginx"
end
