#!/bin/bash
echo "Precompiling assets for production..."
bundler exec rake assets:clean RAILS_ENV=production RAILS_RELATIVE_URL_ROOT=/blacklight
bundler exec rake assets:precompile --trace RAILS_ENV=production RAILS_RELATIVE_URL_ROOT=/blacklight
