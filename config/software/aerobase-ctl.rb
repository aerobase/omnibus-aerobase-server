#
# Copyright:: Copyright (c) 2012 Opscode, Inc.
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

name "aerobase-ctl"
dependency "omnibus-ctl"

license :project_license
source :path => File.expand_path("files/aerobase-ctl-commands", Omnibus::Config.project_root)

build do
  if windows?
    erb source: "aerobase-ctl.bat.erb",
      dest: "#{install_dir}/bin/aerobase-ctl.bat",
      mode: 0755, 
	  vars: {install_dir: "#{install_dir}"}
	  
    erb source: "aerobase-bootstrap.ps1.erb",
      dest: "#{install_dir}/bin/aerobase-bootstrap.ps1",
      mode: 0755

    # Source file copied from https://gist.github.com/se35710/43693e679701387d722206eff1e85f5f
    erb source: "aerobase-find-java.ps1.erb",
      dest: "#{install_dir}/embedded/bin/find-java.ps1",
      mode: 0755
  else
    erb source: "aerobase-ctl.erb",
      dest: "#{install_dir}/bin/aerobase-ctl",
      mode: 0755, 
	  vars: {install_dir: "#{install_dir}"}
  end 

  # additional omnibus-ctl commands
  copy "./*.*", "#{install_dir}/embedded/service/omnibus-ctl/"
end
