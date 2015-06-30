# OmniAuth.config.logger = Rails.logger
#
# OmniAuth.config.on_failure do |env|
#   [200, {}, [env['omniauth.error'].inspect]]
# end


Rails.application.config.middleware.use OmniAuth::Builder do
  provider :saml,
           #:assertion_consumer_service_url     => "http://localhost:3000/auth/saml/callback",
           :issuer                             => "sampleapp-1",
           :idp_sso_target_url                 => "https://localhost:9443/samlsso",
           :idp_sso_target_url_runtime_params  => {:original_request_param => :mapped_idp_param},
           :idp_cert                           => "-----BEGIN CERTIFICATE-----\nMIICNTCCAZ6gAwIBAgIES343gjANBgkqhkiG9w0BAQUFADBVMQswCQYDVQQGEwJVUzELMAkGA1UE
                         CAwCQ0ExFjAUBgNVBAcMDU1vdW50YWluIFZpZXcxDTALBgNVBAoMBFdTTzIxEjAQBgNVBAMMCWxv
                         Y2FsaG9zdDAeFw0xMDAyMTkwNzAyMjZaFw0zNTAyMTMwNzAyMjZaMFUxCzAJBgNVBAYTAlVTMQsw
                         CQYDVQQIDAJDQTEWMBQGA1UEBwwNTW91bnRhaW4gVmlldzENMAsGA1UECgwEV1NPMjESMBAGA1UE
                         AwwJbG9jYWxob3N0MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCUp/oV1vWc8/TkQSiAvTou
                         sMzOM4asB2iltr2QKozni5aVFu818MpOLZIr8LMnTzWllJvvaA5RAAdpbECb+48FjbBe0hseUdN5
                         HpwvnH/DW8ZccGvk53I6Orq7hLCv1ZHtuOCokghz/ATrhyPq+QktMfXnRS4HrKGJTzxaCcU7OQID
                         AQABoxIwEDAOBgNVHQ8BAf8EBAMCBPAwDQYJKoZIhvcNAQEFBQADgYEAW5wPR7cr1LAdq+IrR44i
                         QlRG5ITCZXY9hI0PygLP2rHANh+PYfTmxbuOnykNGyhM6FjFLbW2uZHQTY1jMrPprjOrmyK5sjJR
                         O4d1DeGHT/YnIjs9JogRKv4XHECwLtIVdAbIdWHEtVZJyMSktcyysFcvuhPQK8Qc/E/Wq8uHSCo=\n-----END CERTIFICATE-----",
           :idp_cert_fingerprint               => "6B:F8:E1:36:EB:36:D4:A5:6E:A0:5C:7A:E4:B9:A4:5B:63:BF:97:5D",
           :idp_cert_fingerprint_validator     => lambda { |fingerprint| fingerprint },
           :name_identifier_format             => "urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress"
end