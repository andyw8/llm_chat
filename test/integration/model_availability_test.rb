require "test_helper"

class ModelAvailabilityTest < ActionDispatch::IntegrationTest
  setup do
    @original_openai_api_key = RubyLLM.config.openai_api_key
    @original_openrouter_api_key = RubyLLM.config.openrouter_api_key

    RubyLLM.config.openai_api_key = nil
    RubyLLM.config.openrouter_api_key = "test-key"

    @openai_model = find_model("openai")
    @openrouter_model = find_model("openrouter")
  end

  teardown do
    RubyLLM.config.openai_api_key = @original_openai_api_key
    RubyLLM.config.openrouter_api_key = @original_openrouter_api_key
  end

  test "models index marks models from unconfigured providers unavailable" do
    get models_url

    assert_response :success
    assert_select row_selector(@openai_model) do
      assert_select "*", text: "Unavailable", minimum: 1
      assert_select "a", text: "Start chat", count: 0
    end
    assert_select row_selector(@openrouter_model) do
      assert_select "*", text: "Available", minimum: 1
      assert_select "a", text: "Start chat", count: 1
      assert_select "a[href=?]", model_path(@openrouter_model.id, provider: @openrouter_model.provider),
                    text: @openrouter_model.name
    end
  end

  test "model detail page resolves an id that contains a slash" do
    assert_includes @openrouter_model.id, "/"

    get model_url(@openrouter_model.id, provider: @openrouter_model.provider)

    assert_response :success
    assert_select "*", text: @openrouter_model.name, minimum: 1
  end

  test "new chat only lists models from configured providers" do
    get new_chat_url

    assert_response :success
    assert_select "select[name=?]", "chat[model]" do
      assert_select "option[value^=?]", "openrouter:", minimum: 1
      assert_select "option[value^=?]", "openai:", count: 0
      assert_select "option[value=?]", "", count: 0
    end
  end

  test "new chat falls back to an available model when the requested one is not configured" do
    get new_chat_url(model: ModelCatalog.option_value(@openai_model))

    assert_response :success
    assert_select "select[name=?]", "chat[model]" do
      assert_select "option[selected][value=?]", ModelCatalog.option_value(@openai_model), count: 0
      assert_select "option[value^=?]", "openrouter:", minimum: 1
      assert_select "option[value=?]", "", count: 0
    end
  end

  test "new chat keeps the default option when the default model is configured" do
    RubyLLM.config.openai_api_key = "test-key"

    get new_chat_url

    assert_response :success
    assert_select "select[name=?]", "chat[model]" do
      assert_select "option[value=?]", "", count: 1
    end
  end

  test "new chat explains when no providers are configured" do
    RubyLLM.config.openrouter_api_key = nil

    get new_chat_url

    assert_response :success
    assert_select "select", count: 0
    assert_select "*", text: /No models available/, minimum: 1
  end

  test "model page disables starting a chat with an unavailable model" do
    get model_url(@openai_model.id, provider: @openai_model.provider)

    assert_response :success
    assert_select "button[disabled]", text: "Start chat with this model"
    assert_select "*", text: /Configure an API key for OpenAI/, minimum: 1
  end

  private

  def find_model(provider)
    RubyLLM.models.chat_models.all.find { |model| model.provider.to_s == provider }
  end

  def row_selector(model)
    row_id = [ model.provider, model.id ].join("_").parameterize(separator: "_")
    "tr#model_#{row_id}"
  end
end
