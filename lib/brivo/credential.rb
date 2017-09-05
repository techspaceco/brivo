module Brivo
  class Credential
    attr_reader :id, :reference_id, :field_values

    class << self
      attr_accessor :application

      def create id:, facility_code:
        application.create_credential(id, facility_code)
      end
    end

    def initialize attributes = {}
      @id = attributes['id']
      @reference_id = attributes['referenceId']
      @field_values = attributes['fieldValues']&.map do |field_value|
        field_value.inject({}) do |m, (k, v)|
          m.tap { m[k.to_sym] = v }
        end
      end
    end

    def delete
      application.delete_credential(id)
    end

    def user
      application.credential_user(id)
    end

    private

    def application
      self.class.application
    end
  end
end
