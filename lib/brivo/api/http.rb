module Brivo
  module API
    module HTTP
      MAX_RETRIES = 3
      API_URL = -'https://api.brivo.com/v1/api'
      PAGE_SIZE = 100

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

      def http_request path, method: :get, params: {}, offset: nil
        attempts = 0
        begin
          attempts += 1
          uri = "#{API_URL}/#{path}"

          parsed_uri = URI.parse(uri)

          if offset
            if parsed_uri.query.nil?
              parsed_uri.query = "pageSize=#{PAGE_SIZE}&offset=#{offset}"
            else
              parsed_uri.query = "#{parsed_uri.query}&pageSize=#{PAGE_SIZE}&offset=#{offset}"
            end
          end

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
          when 404
            raise Brivo::NotFound
          when 418
            raise Brivo::TeapotError
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

      private

      def monotonic_time
        Process.clock_gettime(Process::CLOCK_MONOTONIC)
      end
    end
  end
end
