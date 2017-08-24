$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'brivo'

require 'minitest/autorun'
require 'webmock/minitest'
require 'vcr'

VCR.configure do |c|
  c.cassette_library_dir = 'test/fixtures'
  c.hook_into :webmock

  c.filter_sensitive_data('<api key>') { ENV['TEST_BRIVO_API_KEY'] }
  c.filter_sensitive_data('<username>') { ENV['TEST_BRIVO_USERNAME'] }
  c.filter_sensitive_data('<password>') { ENV['TEST_BRIVO_PASSWORD'] }
  c.filter_sensitive_data('<authorization code>') do
    Base64.strict_encode64("#{ENV['TEST_BRIVO_CLIENT_ID']}:#{ENV['TEST_BRIVO_SECRET']}")
  end

  c.filter_sensitive_data('<access token>') do |interaction|
    begin
      body = JSON.parse(interaction.response.body)
      body.dig('access_token')
    rescue JSON::ParserError
    end
  end

  c.filter_sensitive_data('<refresh token>') do |interaction|
    begin
      body = JSON.parse(interaction.response.body)
      body.dig('refresh_token')
    rescue JSON::ParserError
    end
  end

  c.filter_sensitive_data('<access token>') do |interaction|
    authorization_header = interaction.request.headers['Authorization'].first
    if authorization_header.include? 'bearer'
      authorization_header.gsub('bearer ', '')
    end
  end
end

module Brivo::TestClient
  def brivo_client
    @brivo_client ||= Brivo::Application.new(
      client_id: ENV['TEST_BRIVO_CLIENT_ID'],
      secret: ENV['TEST_BRIVO_SECRET'],
      api_key: ENV['TEST_BRIVO_API_KEY'],
      username: ENV['TEST_BRIVO_USERNAME'],
      password: ENV['TEST_BRIVO_PASSWORD']
    )
  end
end

class Minitest::Test
  include Brivo::TestClient
end
