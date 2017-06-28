module Brivo
  class User
    attr_reader :id, :first_name, :last_name, :external_id, :suspended
    class << self
      attr_accessor :application

      def create first_name:, last_name:, external_id: nil, suspended: false
        application.create_user(first_name, last_name, external_id, suspended)
      end
    end

    def initialize attributes = {}
      @id = attributes['id']
      @first_name = attributes['firstName']
      @last_name = attributes['lastName']
      @external_id = attributes['externalId']
      @suspended = attributes['suspended']
    end

    def delete
      application.delete_user(id)
    end

    def groups
      application.user_groups(id)
    end

    def credentials
      application.user_credentials(id)
    end

    def assign_credential credential_id, effective_from, effective_to
      application.user_assign_credential(id, credential_id, effective_from, effective_to)
    end

    def remove_credential credential_id
      application.user_remove_credential(id, credential_id)
    end

    private

    def application
      self.class.application
    end
  end
end
