module Brivo
  class Application
    attr_reader :client_id, :secret, :api_key, :username, :password

    MAX_RETRIES = 3

    def initialize client_id:, secret:, api_key:, username:, password:
      @client_id = client_id
      @secret = secret
      @api_key = api_key
      @username = username
      @password = password

      set_access_token
    end

    # TODO: Organise some of this code and move it into seperate calculate_security_depositcd
    # TODO don't authenticate on every request. Someimes the access token won't have expired yet

    def set_access_token
      uri = URI.parse("https://auth.brivo.com/oauth/token?grant_type=password&username=#{username}&password=#{password}")

      authorization_code = Base64.strict_encode64("#{client_id}:#{secret}")

      res = Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |https|
        req = Net::HTTP::Post.new(uri)
        req['Content-Type'] = 'application/json'
        req['Authorization'] = "Basic #{authorization_code}"
        req['api-key'] = api_key

        https.request(req)
      end

      response = JSON.parse res.body

      @access_token = response['access_token']
      @access_token_expiry = monotonic_time + (response['expires_in'] - 2)
    end

    def http_request uri, method: :get, params: {}
      attempts = 0
      begin
        attempts += 1
        parsed_uri = URI.parse(uri)

        http_methods = {
          get: Net::HTTP::Get,
          post: Net::HTTP::Post,
          put: Net::HTTP::Put,
          delete: Net::HTTP::Delete
        }

        response = Net::HTTP.start(parsed_uri.host, parsed_uri.port, use_ssl: true) do |https|
          request = http_methods[method].new(parsed_uri)
          request.body = params.to_json

          set_access_token if monotonic_time > @access_token_expiry

          request['Content-Type'] = 'application/json'
          request['Authorization'] = "bearer #{@access_token}"
          request['api-key'] = api_key

          https.request(request)
        end

        # http://apidocs.brivo.com/#response-codes
        case response.code.to_i
        when 200
          JSON.parse(response.body)
        when 204
          true
        when 400
          raise Brivo::BadRequest
        when 401
          raise Brivo::Unauthorized
        when 403
          raise Brivo::Forbidden
        when 415
          raise Brivo::UnsupportedMediaType
        when 503
          raise Brivo::ServiceUnavailable
        when 596
          raise Brivo::ServiceNotFound
        else
          raise Brivo::UnkownResponse
        end
      rescue StandardError
        if attempts > MAX_RETRIES
          raise
        else
          retry
        end
      end
    end

    def groups
      result = http_request 'https://api.brivo.com/v1/api/groups'
    end

    def users
      result = http_request 'https://api.brivo.com/v1/api/users'
    end

    def credentials
      result = http_request 'https://api.brivo.com/v1/api/credentials'
    end

    def credential_delete
      result = http_request "https://api.brivo.com/v1/api/credentials/#{credential_id}"
    end

    def user_create first_name, last_name, external_id
      result = http_request(
        'https://api.brivo.com/v1/api/users',
        params: {
          firstName: first_name,
          lastName: last_name,
          externalId: external_id
        },
        method: :post
      )
    end

    def user_assign_credential user_id, credential_id, effective_from, effective_to
      result = http_request(
        "https://api.brivo.com/v1/api/users/#{user_id}/credentials/#{credential_id}",
        method: :put,
        params: {
          effectiveFrom: effective_from,
          effectiveTo: effective_to
        }
      )
    end

    def user_credentials user_id
      result = http_request "https://api.brivo.com/v1/api/users/#{user_id}/credentials"
    end

    def user_remove_credential user_id, credential_id
      http_request "https://api.brivo.com/v1/api/users/#{user_id}/credentials/#{credential_id}", method: :delete
    end

    def user_list_groups user_id
      result = http_request "https://api.brivo.com/v1/api/users/#{user_id}/groups"
    end

    def group_assign_user group_id, user_id
      result = http_request "https://api.brivo.com/v1/api/groups/#{group_id}/users/#{user_id}", method: :put
    end

    def group_remove_user group_id, user_id
      result = http_request "https://api.brivo.com/v1/api/groups/#{group_id}/users/#{user_id}", method: :delete
    end

    def group_list_users group_id
      result = http_request "https://api.brivo.com/v1/api/groups/#{group_id}/users"
    end

    private

    def monotonic_time
      Process.clock_gettime(Process::CLOCK_MONOTONIC)
    end
  end
end
