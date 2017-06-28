module Brivo
  class Group
    attr_reader :id, :name
    class << self
      attr_accessor :application

      def create name:
        application.create_group(name)
      end
    end

    def initialize attributes = {}
      @id = attributes['id']
      @name = attributes['name']
    end

    def delete
      application.delete_group(id)
    end

    def users
      application.group_users(id)
    end

    def assign_user user_id
      application.group_assign_user(id, user_id)
    end

    def remove_user user_id
      application.group_remove_user(id, user_id)
    end

    private

    def application
      self.class.application
    end
  end
end
