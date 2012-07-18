class AddChatTokenToUser < ActiveRecord::Migration
  def up
    add_column :users, :chat_token, :string
  end
  def down
  end
end
