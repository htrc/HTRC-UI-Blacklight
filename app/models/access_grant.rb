class AccessGrant < ActiveRecord::Base
  attr_accessible :access_token, :access_token_expires_at, :application_id, :code, :refresh_token, :user_id
end
