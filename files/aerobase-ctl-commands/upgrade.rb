#
# Copyright:: Copyright (c) 2018.
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

add_command 'upgrade', 'Run migrations after a package upgrade', 1 do |cmd_name|
  auto_migrations_skip_file = "#{etc_path}/skip-auto-migrations"
  if File.exists?(auto_migrations_skip_file)
    log "Found #{auto_migrations_skip_file}, exiting..."
    exit! 0
  end

  # Default location of install-dir is /opt/aerobase/. This path is set during build time.
  # DO NOT change this value unless you are building your own Aerobase packages
  if !::File.exists? "#{etc_path}/aerobase.rb" then
    abort('It looks like aerobase has not been installed yet; skipping the update '\
      'script.')
  end

  conf = File.open("#{base_path}/embedded/cookbooks/upgrade.json", "w")
  conf.puts "{ }"
  conf.close

  status = run_chef("#{base_path}/embedded/cookbooks/upgrade.json", "-l fatal -F null -o recipe[aerobase::upgrade]")
  File.delete("#{base_path}/embedded/cookbooks/upgrade.json")

  log 'Run Aerobase reconfigure to apply migrations'
  log <<EOS

Upgrade complete! If your Aerobase server is misbehaving try running

   sudo aerobase-ctl restart

before anything else. If you need to roll back to the previous version you can
use the database backup made during the upgrade (scroll up for the filename).
EOS
end
