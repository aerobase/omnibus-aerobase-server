source 'https://rubygems.org'
 
# Install omnibus
# Any version higher then 6.1.4 break the 2nd build. gems are not placed in aerobase home
gem 'omnibus', git: 'https://github.com/chef/omnibus.git', tag: '9.0.25'
gem 'omnibus-software', git: 'https://github.com/aerobase/omnibus-software.git', tag: 'kc-upgrade'
gem 'json'

# Use Chef's software definitions. It is recommended that you write your own
# software definitions, but you can clone/fork Chef's to get you started.
# gem 'omnibus-software', github: 'opscode/omnibus-software'

# This development group is installed by default when you run `bundle install`,
# but if you are using Omnibus in a CI-based infrastructure, you do not need
# the Test Kitchen-based build lab. You can skip these unnecessary dependencies
# by running `bundle install --without development` to speed up build times.