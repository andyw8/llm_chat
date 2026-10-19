class ChatsController < ApplicationController
  layout "chats"

  before_action :set_chat, only: [ :show, :destroy ]
  before_action :load_chats, only: [ :index, :show, :new ]

  def index
  end

  def new
    @chat = Chat.new
    @selected_model = params[:provider] ? [ params[:provider], params[:model] ].join(":") : params[:model]
    @chat_models = available_chat_models
  end

  def create
    provider, model = params.dig(:chat, :model).to_s.split(":", 2)
    @chat = Chat.create!(model: model.presence, provider: provider.presence)

    redirect_to @chat, notice: "Chat was successfully created."
  end

  def show
    @message = Message.new
  end

  def destroy
    @chat.destroy!
    redirect_to chats_path, notice: "Chat was successfully destroyed.", status: :see_other
  end

  private

  def load_chats
    @chats = Chat.includes(:messages).order(created_at: :desc)
  end

  def set_chat
    @chat = Chat.find(params[:id])
  end
end
