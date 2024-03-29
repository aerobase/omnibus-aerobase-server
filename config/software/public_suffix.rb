#
# Copyright 2014 Chef Software, Inc.
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

name "public_suffix"
default_version "v5.0.4"

license "Apache-2.0"
license_file "LICENSE.txt"

source git: "https://github.com/weppos/publicsuffix-ruby.git"

dependency "rubygems"
dependency "bundler"

build do
  env = with_standard_compiler_flags(with_embedded_path)

  bundle "config set --local without 'development'", env: env
  bundle "install", env: env

  gem "build public_suffix.gemspec", env: env
  gem "install public_suffix-*.gem" \
      "  --no-document", env: env
end
