module MessagesHelper
  def default_model_display_name
    "Default: #{RubyLLM.models.find(RubyLLM.config.default_model).label}"
  end

  # Server-rendered time is the no-JS fallback; the Stimulus controller
  # rewrites it in the reader's own timezone.
  def local_time_tag(time)
    return unless time

    tag.time(
      time.strftime("%I:%M %p"),
      datetime: time.iso8601,
      data: { controller: "local-time" }
    )
  end

  def tool_result_partial(message)
    name = message.respond_to?(:parent_tool_call) ? message.parent_tool_call&.name.to_s : ""
    partial_for(prefix: "messages/tool_results", name: name)
  end

  def tool_call_partial(tool_call)
    partial_for(prefix: "messages/tool_calls", name: tool_call.name.to_s)
  end

  private

  def partial_for(prefix:, name:)
    normalized = name.to_s.underscore.tr("-", "_")
    if normalized.present? && lookup_context.exists?(normalized, [ prefix ], true)
      "#{prefix}/#{normalized}"
    else
      "#{prefix}/default"
    end
  end
end
