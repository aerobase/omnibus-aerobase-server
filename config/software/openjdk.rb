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

name "openjdk"
default_version "11.0.14.1"
license :project_license
build_bumber = "1"

version "11.0.14.1" do
  if windows?
    source md5: "5ef420c2d337acae88c69ef8642d2830"
  else
    source md5: "d0934cfeb97c62dc979eb2ced0688c08"
  end
end

version "8u192" do
  if windows?
    source md5: "e7d7c4d205d0f3266c09a87785304ee1"
  else
    source md5: "3e1a4419f15c744e2c226af2f6cf7ca4"
  end
end

if windows?
  os = "windows"
  ext = "zip"
else
  os = "linux"
  ext = "tar.gz"
end

source url: "https://github.com/adoptium/temurin11-binaries/releases/download/jdk-#{version}+#{build_bumber}/OpenJDK11U-jre_x64_#{os}_hotspot_#{version}_#{build_bumber}.#{ext}"

relative_path "jdk-#{version}+#{build_bumber}-jre"

build do
  mkdir "#{install_dir}/embedded/openjdk/"
  mkdir "#{install_dir}/embedded/openjdk/jre"
  sync "./", "#{install_dir}/embedded/openjdk/jre/"
end
