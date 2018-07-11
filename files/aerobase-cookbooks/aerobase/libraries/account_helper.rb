#
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

class AccountHelper
  attr_reader :node

  def initialize(node)
    @node = node
  end

  def aerobase_user
    node['unifiedpush']['user']['username']
  end
  
  def aerobase_password
    node['unifiedpush']['user']['password']
  end

  def aerobase_group
    node['unifiedpush']['user']['group']
  end

  def web_server_user
    node['unifiedpush']['web-server']['username']
  end

  def web_server_group
    node['unifiedpush']['user']['group']
  end

  def postgresgl_user
    node['unifiedpush']['postgresql']['username']
  end
  
  def postgresgl_password
    node['unifiedpush']['postgresql']['password']
  end

  def postgresgl_group
    node['unifiedpush']['user']['group']
  end
  
  def cassandra_user
    node['unifiedpush']['cassandra']['user']
  end

  def cassandra_group
    node['unifiedpush']['user']['group']
  end
  
  def users
    %W(
        #{aerobase_user}
        #{web_server_user}
        #{postgresgl_user}
		#{cassandra_user}
      )
  end

  def groups
    %W(
        #{aerobase_group}
        #{web_server_group}
        #{postgresgl_group}
		#{cassandra_group}
      )
  end
  
  def passwords
    %W(
        #{aerobase_password}
        #{postgresgl_password}
      )
  end
end

