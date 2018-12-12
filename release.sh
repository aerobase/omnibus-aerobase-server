#!/bin/bash

# Generate a build ID based on the current time and the PID of this script
build="$(date '+%s')-$$"

# Install/update gems for omnibus-ruby
bundle install

# Do the build and capture its output in a .log file
make do_release 2>&1 | tee -a /tmp/${build}.log

# Check the exit status of `make`, not `tee`
if [[ ${PIPESTATUS[0]} -eq 0 ]]; then
  subject="aerobase-server build ${build} SUCCESS"
else
  subject="aerobase-server build ${build} FAIL"
fi

# We assume that email to the current system user will somehow reach the right
# human eyes
tail -n 20 /tmp/${build}.log | sed 's/.*\r//' | mail -s "${subject}" $(cat ~/.forward)
