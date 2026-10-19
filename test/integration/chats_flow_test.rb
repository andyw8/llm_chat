require "test_helper"

class ChatsFlowTest < ActionDispatch::IntegrationTest
  setup do
    @default_model_display_name = MessagesHelper.instance_method(:default_model_display_name)
    MessagesHelper.define_method(:default_model_display_name) { "Default model" }

    @model = RubyLLM::ActiveRecord::Model.create!(
      model_id: "test-model",
      name: "Test Model",
      provider: "test",
      metadata: {
        "reasoning_options" => [
          { "type" => "effort", "values" => %w[low high] }
        ]
      }
    )
    @chat = Chat.create!(model: @model)
    @chat.messages.create!(role: "user", content: "Hello from the user")
    @chat.messages.create!(role: "assistant", content: "Hello from the assistant")
  end

  teardown do
    MessagesHelper.define_method(:default_model_display_name, @default_model_display_name)
  end

  test "index renders the chats sidebar and the empty detail pane" do
    get chats_url

    assert_response :success
    assert_select "turbo-frame#chat"
    assert_select "a[href=?]", chat_path(@chat), text: /Hello from the user/
    assert_select "a[href=?]", new_chat_path
    assert_select "a[href=?]", models_path
  end

  test "show renders the selected chat transcript and composer" do
    get chat_url(@chat)

    assert_response :success
    assert_select "turbo-frame#chat"
    assert_select "div#messages"
    assert_select "form#new_message"
    assert_select "h1", text: @chat.title
    assert_select "button[aria-label=?]", "Chat settings"
    assert_select "form#chat-settings-form"
    assert_select "input[name=?]", "chat[custom_title]"
    assert_select "textarea[name=?]", "chat[system_prompt]"
    assert_select "select[name=?]", "chat[reasoning_effort]"
    assert_select "input[name=?]", "chat[sampling_temperature]"
    assert_select "div#chat-settings-portal"
    assert_select "[data-poetry-portal-container=?]", "chat-settings-portal", count: 2
  end

  test "update saves the chat's title, system prompt, reasoning effort, and temperature" do
    patch chat_url(@chat), params: {
      chat: {
        custom_title: "Project kickoff",
        system_prompt: "Be concise.",
        reasoning_effort: "high",
        sampling_temperature: "0.4"
      }
    }

    assert_redirected_to chat_url(@chat)

    @chat.reload
    assert_equal "Project kickoff", @chat.custom_title
    assert_equal "Project kickoff", @chat.title
    assert_equal "Be concise.", @chat.system_prompt
    assert_equal "high", @chat.reasoning_effort
    assert_in_delta 0.4, @chat.sampling_temperature
  end

  test "update clears settings when the fields are blank" do
    @chat.update!(
      custom_title: "Project kickoff",
      system_prompt: "Be concise.",
      reasoning_effort: "high",
      sampling_temperature: 0.4
    )

    patch chat_url(@chat), params: {
      chat: { custom_title: "", system_prompt: "", reasoning_effort: "", sampling_temperature: "" }
    }

    assert_redirected_to chat_url(@chat)

    @chat.reload
    assert_nil @chat.custom_title
    assert_equal "Hello from the user", @chat.title
    assert_nil @chat.system_prompt
    assert_nil @chat.reasoning_effort
    assert_nil @chat.sampling_temperature
  end

  test "new renders the new chat form inside the detail frame" do
    get new_chat_url

    assert_response :success
    assert_select "turbo-frame#chat"
    assert_select "form"
  end
end
