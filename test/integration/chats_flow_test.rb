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
    @user_message = @chat.messages.create!(role: "user", content: "Hello from the user")
    @assistant_message = @chat.messages.create!(role: "assistant", content: "Hello from the assistant")
    @usage = RubyLLM::ActiveRecord::Usage.create!(
      chat: @chat, message: @assistant_message, operation: "chat", provider: "test",
      model: "test-model", status: "succeeded",
      input_tokens: 1_200, output_tokens: 340, thinking_tokens: 60, total_cost: 0.000123
    )
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
  end

  test "show renders a delete control for user and assistant messages" do
    get chat_url(@chat)

    assert_response :success
    [ @user_message, @assistant_message ].each do |message|
      assert_select "form[action=?]", chat_message_path(@chat, message) do
        assert_select "input[name=_method][value=delete]"
        assert_select "button[aria-label=?]", "Delete message"
      end
    end
  end

  test "destroy deletes the message and clears it from the transcript" do
    assert_difference -> { Message.count }, -1 do
      delete chat_message_url(@chat, @assistant_message), as: :turbo_stream
    end

    assert_response :success
    assert_turbo_stream action: "remove", target: ActionView::RecordIdentifier.dom_id(@assistant_message)
    assert_not Message.exists?(@assistant_message.id)
    assert Message.exists?(@user_message.id)
  end

  test "show renders each reply's cost and the chat's usage in the settings sheet" do
    get chat_url(@chat)

    assert_response :success
    assert_select "##{ActionView::RecordIdentifier.dom_id(@assistant_message)}", text: /\$0\.000123/
    assert_select "##{ActionView::RecordIdentifier.dom_id(@user_message)}", text: /\$0\.000123/, count: 0

    assert_select "#chat-usage p" do |usage|
      text = usage.text.squish
      assert_includes text, "$0.000123 across 1 request"
      assert_includes text, "1,200 in"
      assert_includes text, "340 out"
      assert_includes text, "60 thinking"
    end
  end

  test "usage reads as unknown rather than free when the provider published no pricing" do
    chat = Chat.create!(model: @model)
    reply = chat.messages.create!(role: "assistant", content: "Unpriced reply")
    RubyLLM::ActiveRecord::Usage.create!(
      chat: chat, message: reply, operation: "chat", provider: "test",
      model: "test-model", status: "succeeded", input_tokens: 10, output_tokens: 5
    )

    get chat_url(chat)

    assert_response :success
    assert_select "##{ActionView::RecordIdentifier.dom_id(reply)}", text: /\$/, count: 0
    assert_select "#chat-usage p", text: /— across 1 request/
  end

  test "destroy redirects to the chat list without a flash notice" do
    delete chat_url(@chat)

    assert_response :see_other
    assert_redirected_to chats_url
    assert_nil flash[:notice]
    assert_not Chat.exists?(@chat.id)
  end

  test "destroy only reaches the messages of the chat in the URL" do
    other_message = Chat.create!(model: @model).messages.create!(role: "user", content: "Elsewhere")

    assert_no_difference -> { Message.count } do
      delete chat_message_url(@chat, other_message), as: :turbo_stream
    end

    assert_response :not_found
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

  test "temperature is hidden and cleared for models that do not support it" do
    @model.update!(metadata: @model.metadata.merge("temperature" => false))
    @chat.update_columns(sampling_temperature: 0.7)

    get chat_url(@chat)
    assert_response :success
    assert_select "input[name=?]", "chat[sampling_temperature]", count: 0

    patch chat_url(@chat), params: { chat: { sampling_temperature: "0.9" } }
    assert_redirected_to chat_url(@chat)

    assert_nil @chat.reload.sampling_temperature
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
