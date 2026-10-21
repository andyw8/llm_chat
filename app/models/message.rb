class Message < ApplicationRecord
  acts_as_message
  has_many_attached :attachments

  # Appends are broadcast inline rather than through `broadcasts_to`, which
  # sends every create to `Turbo::Streams::ActionBroadcastJob`. Those jobs run
  # on a thread pool (Solid Queue workers in production, the async adapter in
  # development) and can finish in any order, so a prompt and the reply it
  # produced could be appended the wrong way round - repaired only by a reload
  # that rendered the transcript in database order. Broadcasting inline keeps
  # the transcript in creation order, and puts the assistant's bubble in place
  # before the streaming chunks that target it arrive.
  after_create_commit -> { broadcast_append_to message_stream }
  after_update_commit -> { broadcast_replace_later_to message_stream }
  after_destroy_commit -> { broadcast_remove_to message_stream }

  def broadcast_append_chunk(content)
    broadcast_append_to message_stream,
      target: "message_#{id}_content",
      content: ERB::Util.html_escape(content.to_s)
  end

  private

  def message_stream
    "chat_#{chat_id}"
  end
end
