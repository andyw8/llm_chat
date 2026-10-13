class MessagesController < ApplicationController
  before_action :set_chat

  def create
    content = params.dig(:message, :content)
    if content.present?
      ChatResponseJob.perform_later(@chat.id, content)

      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to @chat }
      end
    else
      @message = @chat.messages.build
      @message.errors.add(:content, "can't be blank")

      respond_to do |format|
        format.turbo_stream { render :create, status: :unprocessable_content }
        format.html { render "chats/show", status: :unprocessable_content }
      end
    end
  end

  private

  def set_chat
    @chat = Chat.find(params[:chat_id])
  end
end
