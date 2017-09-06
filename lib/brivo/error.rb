# frozen_string_literal: true

module Brivo
  class Error < StandardError
    class BadRequest < Error; end
    class Unauthorized < Error; end
    class Forbidden < Error; end
    class NotFound < Error; end
    class UnsupportedMediaType < Error; end
    class ServiceUnavailable < Error; end
    class ServiceNotFound < Error; end
    class UnkownResponse < Error; end
    class IsATeapot < Error; end
  end
end
