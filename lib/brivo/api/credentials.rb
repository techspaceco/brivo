module Brivo
  module API
    module Credentials
      include Brivo::API::HTTP

      FORMAT_NAME = 'Standard 26 Bit'

      def credentials(status: nil)
        path = 'credentials'
        path += "?filter=status__eq:#{status}" if status
        Brivo::Collection.new(self, path, credential_class)
      end

      def user_credentials(user_id)
        Brivo::Collection.new(self, "users/#{user_id}/credentials", credential_class)
      end

      def credential id = nil
        if id
          credential_json = http_request("credentials/#{id}")
          credential_class.new(credential_json)
        else
          credential_class
        end
      end

      def create_credential id, facility_code
        @credential_formats ||= http_request('credentials/formats')['data']
        credential_format = @credential_formats.find do |format|
          format['name'] == FORMAT_NAME
        end

        credential_json = http_request(
          'credentials',
          params: {
            credentialFormat: {
              id: credential_format['id']
            },
            referenceId: id,
            fieldValues: [
              {id: 1, value: id},
              {id: 2, value: facility_code}
            ]
          },
          method: :post
        )

        credential_class.new(credential_json)
      end

      def delete_credential id
        http_request "credentials/#{id}", method: :delete
      end

      private

      def credential_class
        Brivo::Credential.tap { |klass| klass.application = self }
      end
    end
  end
end
