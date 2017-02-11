require 'test_helper'

class Sep::DangerTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Sep::Danger::VERSION
  end
end
