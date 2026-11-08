require 'dotenv/load'

module Auth
  class Authenticator

    def initialize
      @token = ENV['WANIKANI_AUTH_KEY']
    end

    def get_auth_value
      "Bearer #{@token}"
    end

    def get_base_url
      HTTPS_BASE_URL
    end
  end
end