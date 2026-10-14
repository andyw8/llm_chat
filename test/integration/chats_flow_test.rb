require "test_helper"

class ChatsFlowTest < ActionDispatch::IntegrationTest
  setup do
    @default_model_display_name = MessagesHelper.instance_method(:default_model_display_name)
    MessagesHelper.define_method(:default_model_display_name) { "Default model" }

    @model = RubyLLM::ActiveRecord::Model.create!(
      model_id: "test-model", name: "Test Model", provider: "test"
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
  end

  test "new renders the new chat form inside the detail frame" do
    get new_chat_url

    assert_response :success
    assert_select "turbo-frame#chat"
    assert_select "form"
  end
end
