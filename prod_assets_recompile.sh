#!/bin/bash
echo "Precompiling assets for production..."
rake assets:clean RAILS_ENV=production RAILS_RELATIVE_URL_ROOT=/blacklight
rake assets:precompile --trace RAILS_ENV=production RAILS_RELATIVE_URL_ROOT=/blacklight
