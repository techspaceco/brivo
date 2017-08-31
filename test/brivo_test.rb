require_relative 'test_helper'

class BrivoTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Brivo::VERSION
  end
end
