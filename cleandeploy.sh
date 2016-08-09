#!/bin/bash

if [ -x $1 ]; then
  echo "Must specify the environment!"
  echo "Example: $0 development  or  $0 production"
  exit 1
fi

bundler exec rake assets:clean RAILS_ENV=$1 RAILS_RELATIVE_URL_ROOT=/blacklight
bundler exec rake assets:precompile --trace RAILS_ENV=$1 RAILS_RELATIVE_URL_ROOT=/blacklight
