# frozen_string_literal: true

module Brivo
  class BadRequest < StandardError; end
  class Unauthorized < StandardError; end
  class Forbidden < StandardError; end
  class NotFound < StandardError; end
  class UnsupportedMediaType < StandardError; end
  class ServiceUnavailable < StandardError; end
  class ServiceNotFound < StandardError; end
  class UnkownResponse < StandardError; end
  class IsATeapot < StandardError; end
end
