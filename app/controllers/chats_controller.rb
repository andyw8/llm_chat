class ChatsController < ApplicationController
  layout "chats"

  before_action :set_chat, only: [ :show, :update, :destroy ]
  before_action :load_chats, only: [ :index, :show, :new ]

  def index
  end

  def new
    @chat = Chat.new
    @chat_models = ModelCatalog.available
    @selected_model = selected_chat_model
  end

  def create
    provider, model = params.dig(:chat, :model).to_s.split(":", 2)
    @chat = Chat.create!(model: model.presence, provider: provider.presence)

    redirect_to @chat, notice: "Chat was successfully created."
  end

  def show
    @message = Message.new
    @chat_models = ModelCatalog.available
  end

  def update
    provider, model = params.dig(:chat, :model).to_s.split(":", 2)
    @chat.model = model if model.present?
    @chat.provider = provider if provider.present?
    @chat.assign_attributes(chat_settings_params)
    @chat.save!

    redirect_to @chat, notice: "Chat settings updated."
  end

  def destroy
    @chat.destroy!
    redirect_to chats_path, notice: "Chat was successfully destroyed.", status: :see_other
  end

  private

  def selected_chat_model
    requested = params[:provider] ? [ params[:provider], params[:model] ].join(":") : params[:model]
    return requested if @chat_models.any? { |model| ModelCatalog.option_value(model) == requested }

    ModelCatalog.default_model_option || @chat_models.first&.then { |model| ModelCatalog.option_value(model) }
  end

  def load_chats
    @chats = Chat.includes(:messages).order(created_at: :desc)
  end

  def chat_settings_params
    params.require(:chat).permit(:custom_title, :system_prompt, :reasoning_effort, :sampling_temperature)
  end

  def set_chat
    @chat = Chat.find(params[:id])
  end
end
