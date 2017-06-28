module Brivo
  module API
    module Groups
      include Brivo::API::HTTP

      def groups
        Brivo::Collection.new(self, 'groups', group_class)
      end

      def user_groups(user_id)
        Brivo::Collection.new(self, "users/#{user_id}/groups", group_class)
      end

      def group id = nil
        if id
          group_json = http_request("groups/#{id}")
          group_class.new(group_json)
        else
          group_class
        end
      end

      def group_assign_user group_id, user_id
        http_request "groups/#{group_id}/users/#{user_id}", method: :put
      end

      def group_remove_user group_id, user_id
        http_request "groups/#{group_id}/users/#{user_id}", method: :delete
      end

      def create_group name
        group_json = http_request(
          'groups',
          params: {
            name: name
          },
          method: :post
        )

        group_class.new(group_json)
      end

      def delete_group id
        http_request "groups/#{id}", method: :delete
      end

      private

      def group_class
        Brivo::Group.tap { |klass| klass.application = self }
      end
    end
  end
end
