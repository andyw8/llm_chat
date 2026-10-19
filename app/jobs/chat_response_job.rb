class ChatResponseJob < ApplicationJob
  def perform(chat_id, content)
    chat = Chat.find(chat_id)
    apply_settings(chat)

    chat.ask(content) do |chunk|
      if chunk.content && !chunk.content.empty?
        message = chat.messages.last
        message.broadcast_append_chunk(chunk.content)
      end
    end
  end

  private

  # Temperature and instructions live on the chat record, so every reply
  # (including tool continuations in this same job) picks up the current
  # settings. The system prompt is applied at request time rather than
  # persisted as a message: it is configuration, not conversation history.
  def apply_settings(chat)
    if chat.sampling_temperature.present? && chat.supports_temperature?
      chat.with_temperature(chat.sampling_temperature)
    end
    chat.with_instructions(chat.system_prompt, persist: false) if chat.system_prompt.present?

    if chat.reasoning_effort.present? && chat.available_reasoning_efforts.include?(chat.reasoning_effort)
      chat.with_thinking(effort: chat.reasoning_effort)
    end
  end
end
