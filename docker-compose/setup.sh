#!/bin/bash

get_full_path() {
    # Absolute path to this script, e.g. /home/user/bin/foo.sh
    SCRIPT=$(readlink -f $0)

    if [ ! -d ${SCRIPT} ]; then
        # Absolute path this script is in, thus /home/user/bin
        SCRIPT=`dirname $SCRIPT`
    fi

    ( cd "${SCRIPT}" ; pwd )
}

SCRIPT_PATH="$(get_full_path ./)"

main(){
  # Download selected version from bintray
  if [ ! -f "/tmp/aerobase-${AEROBASE_VERSION}.el7.x86_64.rpm" ]; then
    curl -L "https://dl.bintray.com/aerobase/aerobase-rpm/aerobase-${AEROBASE_VERSION}.el7.x86_64.rpm" -o /tmp/aerobase-${AEROBASE_VERSION}.el7.x86_64.rpm
  fi

  if [ ! -f "/tmp/keycloak-server-${KEYCLOAK_VERSION}.el7.x86_64.rpm" ]; then
    curl -L "https://dl.bintray.com/aerobase/aerobase-rpm/keycloak-server-${KEYCLOAK_VERSION}.el7.x86_64.rpm" -o /tmp/keycloak-server-${KEYCLOAK_VERSION}.el7.x86_64.rpm
  fi

  # Install version 
  rpm -U --force /tmp/aerobase-*.rpm
  rpm -U --force /tmp/keycloak-*.rpm

  # Setup default configuration
  if [ -f "/etc/aerobase/ssl/$(hostname).crt" ]; then
    PROTOCOL="https"
  else
    PROTOCOL="http"
  fi
    
  sed -i "s|external_url .*|external_url '${PROTOCOL}://$(hostname)'|g" /etc/aerobase/aerobase.rb
 
  # Configure Aerobase
  aerobase-ctl stop
  aerobase-ctl reconfigure --accept-license
}

# Defaults
AEROBASE_VERSION="2.1.0-1"
KEYCLOAK_VERSION="2.1.0-1"

while [ -n "$1" ]; do
    v="${1#*=}"
    case "$1" in
        --aerobase-version=*)
            export AEROBASE_VERSION="${v}"
            ;;
        --keycloak-version=*)
            export KEYCLOAK_VERSION="${v}"
	    ;;
        --debug)
            DEBUG=1
            print_debug "Debug is ON..."
            ;;
        --help|*)
            cat <<__EOF__
Usage: $0
	--aerobase-version=version  - Aerobase version to use (default 2.2.0-1)
	--keycloak-version=version  - Keycloak version to use (default 2.2.0-1)
        --debug                     - prints debug statement when such are available in the script
__EOF__
        exit 1
    esac
    shift
done

trap revert 1
umask 0022
main
exit 
