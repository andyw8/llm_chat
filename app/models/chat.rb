class Chat < ApplicationRecord
  acts_as_chat

  TITLE_LENGTH = 60

  normalizes :system_prompt, with: ->(prompt) { prompt.to_s.strip.presence }
  normalizes :custom_title, with: ->(title) { title.to_s.strip.presence }
  normalizes :reasoning_effort, with: ->(effort) { effort.to_s.strip.presence }

  validates :sampling_temperature,
    numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 2 },
    allow_nil: true

  before_save :clear_unsupported_reasoning_effort, :clear_unsupported_sampling_temperature

  def title
    custom_title.presence || default_title
  end

  # The title derived from the first user message, used when the reader has
  # not overridden it.
  def default_title
    snippet = messages.find { |message| message.role == "user" }&.content
    snippet.present? ? snippet.squish.truncate(TITLE_LENGTH) : "Chat ##{id}"
  end

  # Whether the current model exposes a temperature control. The registry only
  # marks this explicitly false for models that reject the parameter.
  def supports_temperature?
    model.nil? || model.to_llm.metadata[:temperature] != false
  end

  # The reasoning-effort values the current model accepts, straight from the
  # registry metadata. Empty when the model has no effort control.
  def available_reasoning_efforts
    model ? model.to_llm.reasoning_option_values(:effort) : []
  end

  private

  def clear_unsupported_sampling_temperature
    self.sampling_temperature = nil if sampling_temperature.present? && !supports_temperature?
  end

  # Runs after acts_as_chat's resolve_model, so switching to a model without
  # this effort clears the stale value instead of sending it.
  def clear_unsupported_reasoning_effort
    return if reasoning_effort.blank?

    self.reasoning_effort = nil unless available_reasoning_efforts.include?(reasoning_effort)
  end
end
