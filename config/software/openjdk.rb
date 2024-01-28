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
default_version "17"
license :project_license
build_bumber = "0.10"

version "17" do
  if windows?
    source sha256: "c98d85c8417703b0f72ddc5757ed66f3478ea7107b0e6d2a98cadbc73a45d77b"
  else
    source sha256: "e4fb2df9a32a876afb0a6e17f54c594c2780e18badfa2e8fc99bc2656b0a57b1"
  end
end

if windows?
  os = "windows"
  ext = "zip"
else
  os = "linux"
  ext = "tar.gz"
end

source url: "https://download.oracle.com/java/17/latest/jdk-#{version}_#{os}-x64_bin.#{ext}"

relative_path "jdk-#{version}.#{build_bumber}"

build do
  mkdir "#{install_dir}/embedded/openjdk/"
  mkdir "#{install_dir}/embedded/openjdk/jre"
  sync "./", "#{install_dir}/embedded/openjdk/jre/"
end
