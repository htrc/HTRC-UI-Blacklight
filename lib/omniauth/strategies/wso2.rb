require 'omniauth/strategies/oauth2'

require 'oauth2'
require "multi_json"
require "rest-client"

module OmniAuth
  module Strategies
    class WSO2 < OmniAuth::Strategies::OAuth2
     
      option :name, "wso2"

      #option :client_options, {
      #      :site =>  "https://htrc3.pti.indiana.edu:9443/oauth2/authorize",
      #      :authorize_url => "https://htrc3.pti.indiana.edu:9443/oauth2/authorize",
      #      :access_token_url => "https://htrc3.pti.indiana.edu:9443/oauth2endpoints/token",
      #      :token_url => "https://htrc3.pti.indiana.edu:9443/oauth2endpoints/token"
      #}

      option :token_params, {
        :grant_type => "authorization_code"
      }

      option :provider_ignores_state, true

      option :access_token_options, {
          :mode => :query,
          :param_name => :access_token
      }       

      uid { 
       # raw_info['id'] 
         raw_info['email'] 
      }

      info do
        {
          :name => raw_info['authorized_user'],
          :email => "#{raw_info['authorized_user']}@htrc.org"
          #:email => raw_info['email']
        }
      end

      extra do
      {
        'raw_info' => raw_info
      }
      end

      def raw_info
         @raw_info = {}
         response = RestClient.post(APP_CONFIG['userinfo_url'], 
	 	:access_token => access_token.token, :client_id => client.id, :client_secret => client.secret)
         user = MultiJson.decode(response.to_s)
#Rails.logger.info("#{user.inspect}")
         @raw_info.merge!(user)
      end
    end
  end
end
