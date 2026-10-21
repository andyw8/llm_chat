require "test_helper"
require "action_cable/test_helper"
require "turbo/broadcastable/test_helper"

class MessageBroadcastTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper
  include Turbo::Broadcastable::TestHelper

  setup do
    @chat = Chat.create!
  end

  # `broadcasts_to` sends each create through a background job, so the prompt
  # and the reply could be appended in either order (and the reply's streaming
  # chunks could beat the bubble they target). Appending inline keeps the
  # transcript in creation order.
  test "new messages are appended inline, in the order they were created" do
    payloads = capture_turbo_stream_broadcasts(stream) do
      assert_no_enqueued_jobs only: Turbo::Streams::ActionBroadcastJob do
        @chat.messages.create!(role: "user", content: "Hello there")
        @chat.messages.create!(role: "assistant", content: "General Kenobi")
      end
    end

    assert_equal %w[append append], payloads.map { |payload| payload["action"] }
    assert_equal [ "messages", "messages" ], payloads.map { |payload| payload["target"] }
    assert_includes payloads.first.at("template").inner_html, "Hello there"
    assert_includes payloads.last.at("template").inner_html, "General Kenobi"
  end

  private

  def stream
    "chat_#{@chat.id}"
  end
end
