module Brivo
  class Credential
    attr_reader :id, :reference_id

    class << self
      attr_accessor :application
    end

    def initialize attributes = {}
      @id = attributes['id']
      @reference_id = attributes['referenceId']
    end

    def delete
      application.delete_credential(id)
    end

    private

    def application
      self.class.application
    end
  end
end
