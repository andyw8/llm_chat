class Chat < ApplicationRecord
  acts_as_chat

  TITLE_LENGTH = 60

  def title
    snippet = messages.find { |message| message.role == "user" }&.content
    snippet.present? ? snippet.squish.truncate(TITLE_LENGTH) : "Chat ##{id}"
  end
end
