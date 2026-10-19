require "test_helper"

class ModelCatalogTest < ActiveSupport::TestCase
  setup do
    @original_openai_api_key = RubyLLM.config.openai_api_key
    @original_openrouter_api_key = RubyLLM.config.openrouter_api_key

    RubyLLM.config.openai_api_key = nil
    RubyLLM.config.openrouter_api_key = nil
  end

  teardown do
    RubyLLM.config.openai_api_key = @original_openai_api_key
    RubyLLM.config.openrouter_api_key = @original_openrouter_api_key
  end

  test "available? follows the provider's configuration requirements" do
    RubyLLM.config.openrouter_api_key = "test-key"

    assert ModelCatalog.available?(find_model("openrouter"))
    refute ModelCatalog.available?(find_model("openai"))
  end

  test "available only includes models from configured providers" do
    RubyLLM.config.openrouter_api_key = "test-key"

    available_ids = ModelCatalog.available.map(&:id)

    assert_includes available_ids, find_model("openrouter").id
    refute_includes available_ids, find_model("openai").id
  end

  test "all is sorted by provider then name" do
    keys = ModelCatalog.all.map { |model| [ model.provider.to_s, model.name.to_s ] }

    keys.each_cons(2) do |left, right|
      assert_operator(left <=> right, :<=, 0, "#{left.inspect} should sort before #{right.inspect}")
    end
  end

  test "default_model_available? checks the default model's provider" do
    RubyLLM.config.openai_api_key = "test-key"
    assert ModelCatalog.default_model_available?

    RubyLLM.config.openai_api_key = nil
    refute ModelCatalog.default_model_available?
  end

  private

  def find_model(provider)
    RubyLLM.models.chat_models.all.find { |model| model.provider.to_s == provider }
  end
end
