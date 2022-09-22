class AddChatIdToMatch < ActiveRecord::Migration[5.2]
  def change
    add_column :matches, :chat_id, :integer
  end
end
