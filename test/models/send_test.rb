require "test_helper"

class SendTest < ActiveSupport::TestCase
  test "Send empty list of files" do
    sync = Sync.create!(sender_payload: Sender::Payload.first)
    Sender::Send.send('/tmp', [], '/tmp', sync)
    assert 100, sync.progress
  end
end
