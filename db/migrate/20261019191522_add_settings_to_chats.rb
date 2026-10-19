class AddSettingsToChats < ActiveRecord::Migration[8.1]
  def change
    add_column :chats, :system_prompt, :text
    add_column :chats, :sampling_temperature, :float
  end
end
