class ChatsController < ApplicationController
  before_action :set_chat, only: [ :show, :destroy ]

  def index
    @chats = Chat.order(created_at: :desc)
  end

  def new
    @chat = Chat.new
    @selected_model = params[:provider] ? [ params[:provider], params[:model] ].join(":") : params[:model]
    @chat_models = available_chat_models
  end

  def create
    prompt = params.dig(:chat, :prompt)
    if prompt.present?
      provider, model = params.dig(:chat, :model).to_s.split(":", 2)
      @chat = Chat.create!(model: model.presence, provider: provider.presence)
      ChatResponseJob.perform_later(@chat.id, prompt)

      redirect_to @chat, notice: "Chat was successfully created."
    else
      @chat = Chat.new
      @chat.errors.add(:prompt, "can't be blank")
      @selected_model = params.dig(:chat, :model)
      @chat_models = available_chat_models

      render :new, status: :unprocessable_content
    end
  end

  def show
    @message = Message.new
  end

  def destroy
    @chat.destroy!
    redirect_to chats_path, notice: "Chat was successfully destroyed.", status: :see_other
  end

  private

  def set_chat
    @chat = Chat.find(params[:id])
  end
end
