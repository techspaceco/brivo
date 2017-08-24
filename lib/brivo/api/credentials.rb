# frozen_string_literal: true

module Brivo
  module API
    module Credentials
      include Brivo::API::HTTP

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
