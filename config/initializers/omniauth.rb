OmniAuth.config.logger = Rails.logger

OmniAuth.config.on_failure do |env|
  [200, {}, [env['omniauth.error'].inspect]]
end

# 2014-11-20 cf adding middleware for use in single single sign-on
# https://github.com/PracticallyGreen/omniauth-saml

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :saml,
           # assertion_consumer_service_url:The URL at which the SAML assertion should be received, defaults to the OmniAuth callback URL
           #:assertion_consumer_service_url     => APP_CONFIG['callback_url'],#defaults to the OmniAuth callback URL

           # issuer:The name of this application.
           :issuer                             => "BlackLight",

           # idp_sso_target_url:The URL to which the authentication request should be sent.
           :idp_sso_target_url                 => APP_CONFIG['authorize_url'],

           #idp_sso_target_url_runtime_params:A dynamic mapping of request params that exist during the request phase of OmniAuth that should to be sent to the IdP after a specific mapping.
           #:idp_sso_target_url_runtime_params  => {:original_request_param => :mapped_idp_param},

           #idp_cert:The identity provider's certificate in PEM format.
           :idp_cert                           => "-----BEGIN CERTIFICATE-----\n...-----END CERTIFICATE-----",

           #idp_cert_fingerprint:The SHA1 fingerprint of the certificate, e.g. "90:CC:16:F0:8D:...".
           :idp_cert_fingerprint               => "E7:91:B2:E1:...",

           #name_identifier_format:Used during SP-initiated SSO. Describes the format of the username required by this application.
           #                      If not specified, the IdP is free to choose the name identifier format used in the response.
           #:name_identifier_format             => "urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress"
end
