#!/bin/bash
echo Starting Blacklight in the background w/passenger...
#RAILS_RELATIVE_URL_ROOT="/blacklight" rails server --environment=production --daemon
RAILS_RELATIVE_URL_ROOT="/blacklight" passenger start --environment=development --daemon