#
# Copyright:: Copyright (c) 2018, Aerobase Inc
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

password = node['keytab_help_password']
user = node['keytab_help_user']

puts ""
puts "##############################################################################"
puts "########################## Key Tab HELP commands #############################"
puts "#                                                                            #"
puts "#                                                                            #"
puts "# The following commands demonstrate how to set an spn and generate a key    #"
puts "# tab on windows active directory.                                           #"
puts "# Output commands are according to current domain name.                      #"
puts "#                                                                            #"
puts "#                                                                            #"
puts "# 1. setspn                                                                  #"
puts "# setspn -A HTTP/#{node['fqdn']} #{user}                                      "
puts "#                                                                            #"
puts "# 2. crete keytab file                                                       #"
puts "# ktpass -out #{user}.keytab \\                                               " 
puts "   -princ HTTP/#{node['fqdn']}@#{node['domain'].upcase} \\                    "
puts "   -mapUser #{user} -mapOp set -pass #{password} -kvno 0 -crypto all \\       "
puts "   -pType KRB5_NT_PRINCIPAL                                                  #"
puts "#                                                                            #"
puts "#                                                                            #"
puts "# Copy Commands 1/2 and execute on your Active Directory Server.             #"
puts "# Use output keytab to configure kerberos integration.                       #"
puts "##############################################################################"
puts "##############################################################################"
