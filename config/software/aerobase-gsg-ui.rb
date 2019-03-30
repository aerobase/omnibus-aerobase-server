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

name "aerobase-gsg-ui"
default_version "v2.2.3"
license :project_license

source git: "https://github.com/aerobase/aerobase-gsg-ui.git"

relative_path "aerobase-gsg-ui"
build_dir = "#{project_dir}"

build do
  if windows?
    command "mvn install"
  else
    command "npm install"
    command "npm run build"
  end

  # Copy dist to package dir.
  command "mkdir -p #{install_dir}/embedded/apps/aerobase-gsg-ui"
  sync "./dist/", "#{install_dir}/embedded/apps/aerobase-gsg-ui"
end
