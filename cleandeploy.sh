rake assets:clean RAILS_ENV=$1
rake assets:precompile --trace RAILS_ENV=$1 RAILS_RELATIVE_URL_ROOT=/blacklight