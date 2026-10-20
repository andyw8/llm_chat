# ruby_llm does not read the environment itself, so each provider's key is
# wired to its conventional environment variable here. A key is only set when
# a value is present, so an unconfigured provider still raises its "not
# configured" error rather than failing with a blank key. The same name is
# looked up in Rails credentials as a fallback.
RubyLLM.configure do |config|
  config.openai_api_key = ENV["OPENAI_API_KEY"].presence || Rails.application.credentials.dig(:openai_api_key)
  config.anthropic_api_key = ENV["ANTHROPIC_API_KEY"].presence || Rails.application.credentials.dig(:anthropic_api_key)
  config.azure_api_key = ENV["AZURE_API_KEY"].presence || Rails.application.credentials.dig(:azure_api_key)
  config.bedrock_api_key = ENV["BEDROCK_API_KEY"].presence || Rails.application.credentials.dig(:bedrock_api_key)
  config.cohere_api_key = ENV["COHERE_API_KEY"].presence || Rails.application.credentials.dig(:cohere_api_key)
  config.deepgram_api_key = ENV["DEEPGRAM_API_KEY"].presence || Rails.application.credentials.dig(:deepgram_api_key)
  config.deepseek_api_key = ENV["DEEPSEEK_API_KEY"].presence || Rails.application.credentials.dig(:deepseek_api_key)
  config.elevenlabs_api_key = ENV["ELEVENLABS_API_KEY"].presence || Rails.application.credentials.dig(:elevenlabs_api_key)
  config.gemini_api_key = ENV["GEMINI_API_KEY"].presence || Rails.application.credentials.dig(:gemini_api_key)
  config.gpustack_api_key = ENV["GPUSTACK_API_KEY"].presence || Rails.application.credentials.dig(:gpustack_api_key)
  config.hetzner_api_key = ENV["HETZNER_API_KEY"].presence || Rails.application.credentials.dig(:hetzner_api_key)
  config.mistral_api_key = ENV["MISTRAL_API_KEY"].presence || Rails.application.credentials.dig(:mistral_api_key)
  config.ollama_api_key = ENV["OLLAMA_API_KEY"].presence || Rails.application.credentials.dig(:ollama_api_key)
  config.ollama_cloud_api_key = ENV["OLLAMA_CLOUD_API_KEY"].presence || Rails.application.credentials.dig(:ollama_cloud_api_key)
  config.openrouter_api_key = ENV["OPENROUTER_API_KEY"].presence || Rails.application.credentials.dig(:openrouter_api_key)
  config.perplexity_api_key = ENV["PERPLEXITY_API_KEY"].presence || Rails.application.credentials.dig(:perplexity_api_key)
  config.typesafe_api_key = ENV["TYPESAFE_API_KEY"].presence || Rails.application.credentials.dig(:typesafe_api_key)
  config.xai_api_key = ENV["XAI_API_KEY"].presence || Rails.application.credentials.dig(:xai_api_key)

  # config.default_model = "gpt-5-nano"
end
