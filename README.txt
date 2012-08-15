# To precompile assets for production mode run:
RAILS_RELATIVE_URL_ROOT="/blacklight" rake assets:precompile

# To run in production mode in background:
RAILS_RELATIVE_URL_ROOT="/blacklight" rails s -e production -d
