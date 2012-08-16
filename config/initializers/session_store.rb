# Be sure to restart your server when you modify this file.

# BlacklightHtrc::Application.config.session_store :cookie_store, :key => '_blacklight_htrc_session'
 
# Use database for sessions instead of cookies for large collections
# Generate a migration that creates the session table
#  rake db:sessions:create
# Run the migration
#  rake db:migrate
BlacklightHtrc::Application.config.session_store :active_record_store, :key => '_blacklight_htrc_session'

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rails generate session_migration")
# BlacklightHtrc::Application.config.session_store :active_record_store
