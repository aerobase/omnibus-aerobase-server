#
# Copyright:: Copyright (c) 2017
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

# Define apache cassandra cookbook attributes.
CassandraHelper.new(node)

# Install apache cassandra from external package
include_recipe 'cassandra-dse' if node['unifiedpush']['cassandra']['enable']
include_recipe 'unifiedpush::cassandra_keyspace' if node['unifiedpush']['cassandra']['enable']

cassandra_log_dir = node['unifiedpush']['cassandra']['log_directory']
cassandra_home_dir = node['unifiedpush']['cassandra']['home_dir']

link cassandra_log_dir do
  to File.join(cassandra_home_dir, "logs")
end

runit_service "cassandra" do
  down node['unifiedpush']['cassandra']['ha']
  control ['d']
  options({
    :log_directory => cassandra_log_dir
  }.merge(params))
  log_options node['unifiedpush']['logging'].to_hash.merge(node['unifiedpush']['cassandra'].to_hash)
end

# Make sure cassandra execution in not bloked by selinux
# This is required only because installation_dir is symbolic link.
execute "restorecon-cassandra-slink" do
  command "restorecon -Rv #{node['unifiedpush']['cassandra']['installation_dir']}"
  action :run
end

if node['unifiedpush']['bootstrap']['enable']
  execute "/opt/unifiedpush/bin/unifiedpush-ctl start cassandra" do
    retries 5
  end
end

