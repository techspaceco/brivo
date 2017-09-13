# frozen_string_literal: true

module Brivo
  class Application
    include Brivo::API::Users
    include Brivo::API::Groups
    include Brivo::API::Credentials

    attr_reader :client_id, :secret, :api_key, :username, :password

    def initialize client_id:, secret:, api_key:, username:, password:
      @client_id = client_id
      @secret = secret
      @api_key = api_key
      @username = username
      @password = password
    end
  end
end
