require 'omniauth/strategies/oauth2'

require 'oauth2'
require 'multi_json'
require 'rest-client'

module OmniAuth
  module Strategies
    class WSO2 < OmniAuth::Strategies::OAuth2
     
      option :name, 'wso2'

      # client_options hash now set via devise initializer
      #option :client_options, {
      #      :site =>  "https://htrc3.pti.indiana.edu:9443/oauth2/authorize",
      #      :authorize_url => "https://htrc3.pti.indiana.edu:9443/oauth2/authorize",
      #      :access_token_url => "https://htrc3.pti.indiana.edu:9443/oauth2endpoints/token",
      #      :token_url => "https://htrc3.pti.indiana.edu:9443/oauth2endpoints/token"
      #}

      option :token_params, {
        :grant_type => 'authorization_code'
      }

      option :provider_ignores_state, true

      option :access_token_options, {
          :mode => :query,
          :param_name => :access_token
      }       

      uid {
         # raw_info['id'] 
         raw_info['authorized_user'] 
      }

      info do {
          :lastname => raw_info['family_name'],
          :givenname => raw_info['given_name'],
          :email => raw_info['http://wso2.org/oidc/claim/email'],
          :name => "#{raw_info['given_name']} #{raw_info['family_name']}"
      }

      end

      extra do
      {
        'raw_info' => raw_info
      }
      end

      def raw_info
        @raw_info = {}

        #RestClient.add_before_execution_proc do |req, params|
        #  Rails.logger.warn "req: #{req.inspect}, params:#{params.to_s} time: "#{Time.now.to_i}""
        #end
        
        response = RestClient.get("#{APP_CONFIG['userinfo_url']}?client_id=#{client.id}&client_secret=#{client.secret}&schema=openid",
                                  { :authorization => "Bearer #{access_token.token}", :content_type => :json }  )
        
        #Rails.logger.warn "user response from user info call: #{response.to_s}"

        user = MultiJson.decode(response.to_s)

         @raw_info.merge!(user)
      end

      def callback_url
        APP_CONFIG['callback_url']
      end

    end
  end
end
