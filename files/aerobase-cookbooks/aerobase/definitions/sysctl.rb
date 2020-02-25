#
# Copyright:: Copyright (c) 2015 GitLab B.V.
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

define :sysctl, value: nil do
  param = params[:name]
  value = params[:value]

  directory "/etc/sysctl.d" do
    mode "0755"
    recursive true
  end

  file "/opt/aerobase/embedded/etc/90-omnibus-aerobase.conf" do
    action :touch
  end

  bash "add #{param} settings" do
    user "root"
    code <<-EOF
      echo '#{param} = #{value}' >> /opt/aerobase/embedded/etc/90-omnibus-aerobase.conf
    EOF
    notifies :run, 'execute[sysctl]', :immediately
    not_if "sysctl -n #{param} | grep -q -x #{value}"
  end

  link "/etc/sysctl.d/90-omnibus-aerobase.conf" do
    to "/opt/aerobase/embedded/etc/90-omnibus-aerobase.conf"
  end

  # Load the settings right away
  execute "sysctl" do
    command "cat /etc/sysctl.conf /etc/sysctl.d/*.conf  | sysctl -e -p -"
    action :nothing
  end
end
