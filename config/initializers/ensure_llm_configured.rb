# Without a usable chat model the app can do nothing, so fail when the
# server starts instead of serving an empty chat screen. Only `rails server`
# is checked: db tasks, the console, and tests still boot without a key.
Rails.application.config.after_initialize do
  next unless defined?(Rails::Server)
  next if Rails.env.test?
  next if ModelCatalog.configured?

  abort <<~MESSAGE
    No LLM provider is configured, so the server cannot start.

    Set an API key for at least one provider, for example:
      export OPENROUTER_API_KEY=...
      export OPENAI_API_KEY=...

    Keys can also be stored in Rails credentials (e.g. `openai_api_key`).
  MESSAGE
end
