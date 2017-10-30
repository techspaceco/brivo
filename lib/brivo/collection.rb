# frozen_string_literal: true

module Brivo
  class Collection
    include Enumerable

    def initialize application, api_path, model
      @application = application
      @api_path = api_path
      @model = model
      @collection = []

      fetch_collection
    end


    def each(&block)
      total_count = @total_count
      while @collection.count < total_count do
        collection_count = @collection.count
        fetch_collection(offset: collection_count)
      end

      @collection.each(&block)
    end

    private

    def fetch_collection offset: 0
      response = @application.http_request(@api_path, offset: offset)
      @total_count = response['count']
      response['data'].each do |json|
        @collection << @model.new(json)
      end
    end
  end
end
