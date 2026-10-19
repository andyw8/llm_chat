class AddReasoningEffortAndCustomTitleToChats < ActiveRecord::Migration[8.1]
  def change
    add_column :chats, :reasoning_effort, :string
    add_column :chats, :custom_title, :string
  end
end
