#!/bin/bash
echo Starting Workset Builder in the background w/passenger...
RAILS_RELATIVE_URL_ROOT="/blacklight" passenger start --log-file=/var/log/htrc/workset-builder/passenger.log  --environment=development --daemon