module Dineros
  class App < Padrino::Application
    use ActiveRecord::ConnectionAdapters::ConnectionManagement
    register Padrino::Rendering
    register Padrino::Mailer
    register Padrino::Helpers
    register Kaminari::Helpers::SinatraHelpers

    enable :sessions

    set :delivery_method, :sendmail
    set :mailer_defaults, from: "Pescatemps <#{ENV['EMAIL_ADMIN']}>"

    # soluciona problemas con valudacion de token en chromium
    # https://github.com/padrino/padrino-framework/issues/1251
    set :protect_from_csrf, false

  end
end
