module Brivo
  module API
    module Users
      include Brivo::API::HTTP

      def users
        Brivo::Collection.new(self, 'users', user_class)
      end

      def group_users group_id
        Brivo::Collection.new(self, "groups/#{group_id}/users", user_class)
      end

      def credential_user credential_id
        user_json = http_request("credentials/#{credential_id}/user")
        user_class.new(user_json)
      end

      def user id = nil, external_id: nil
        if id
          user_json = http_request "users/#{id}"
          user_class.new(user_json)
        elsif external_id
          user_json = http_request "users/#{external_id}/external"
          user_class.new(user_json)
        else
          user_class
        end
      end

      def create_user first_name, last_name, external_id, suspended = false
        user_json = http_request(
          'users',
          params: {
            firstName: first_name,
            lastName: last_name,
            externalId: external_id,
            suspended: suspended
          },
          method: :post
        )

        user_class.new(user_json)
      end

      def delete_user id
        http_request "users/#{id}", method: :delete
      end

      def user_assign_credential user_id, credential_id, effective_from, effective_to
        http_request(
          "users/#{user_id}/credentials/#{credential_id}",
          method: :put,
          params: {
            effectiveFrom: effective_from,
            effectiveTo: effective_to
          }
        )
      end

      def user_remove_credential user_id, credential_id
        http_request "users/#{user_id}/credentials/#{credential_id}", method: :delete
      end

      private

      def user_class
        Brivo::User.tap { |klass| klass.application = self }
      end
    end
  end
end
