#
# Copyright:: Copyright (c) 2015
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

name "aerobase-cookbooks"
license :project_license
skip_transitive_dependency_licensing true

source :path => File.expand_path("files/aerobase-cookbooks", Omnibus::Config.project_root)

build do
  command "mkdir -p #{install_dir}/embedded/cookbooks"
  sync "./", "#{install_dir}/embedded/cookbooks/"
  
  # Create a package cookbook.
  command "mkdir -p #{install_dir}/embedded/cookbooks/package/attributes"
  erb :dest => "#{install_dir}/embedded/cookbooks/package/attributes/default.rb",
    :source => "cookbook_packages_default.erb",
    :mode => 0755,
    :vars => { 
		:install_dir => project.install_dir,		
		:name => project.name,
		:runtime_dir => '/var/opt/' + project.name,
		:logs_dir => '/var/log/' + project.name,
		:config_dir => '/etc/' + project.name,
	}
end
