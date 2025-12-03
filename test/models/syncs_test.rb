require "test_helper"

class SyncsTest < ActiveSupport::TestCase
  test "Delete sync is not blocked by foreign key violation" do
    syncs(:done).destroy
  end
end
