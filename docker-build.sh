#!/bin/bash

# Debian & Ubuntu are ignoring .bashrc file
# Export all path variables manually.

# Maven 
export M2_HOME=/usr/local/maven
export M2="$M2_HOME/bin"
PATH="$M2:$PATH"

# Ruby 
export PATH="/var/lib/jenkins/.rbenv/bin:$PATH"
eval "$(/var/lib/jenkins/.rbenv/bin/rbenv init -)"
export PATH="/var/lib/jenkins/.rbenv/plugins/ruby-build/bin:$PATH"

# Node JS
export NVM_DIR="/var/lib/jenkins/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8
export LC_ALL=en_US.UTF-8

rbenv global 2.7.2

ruby -v 
gem -v
mvn -v 
git --version

gem install bundler -v 2.2.8
gem install omnibus -v 8.0.9
gem install rack -v 2.2.3.1

bundle update
bundle install --without development --binstubs
gem install berkshelf -v 7.0.10
berks vendor files/aerobase-cookbooks/

git submodule init
git submodule update

if [ "${CLEAN_CACHE}" == "true" ]; then
	bin/omnibus clean aerobase --purge
fi

# Remove old packages 
rm -rf "${WORKSPACE}"/pkg/aerobase*

# Build version
bundle exec omnibus build aerobase
