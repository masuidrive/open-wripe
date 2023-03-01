require 'localhost/authority'
authority = Localhost::Authority.fetch

if "development" == ENV.fetch("RAILS_ENV") { "development" }
  ssl_bind '127.0.0.1', '3001', {
    key: authority.key_path,
    cert: authority.certificate_path
  }
end
