class ChangeComment < ActiveRecord::Migration
  def change
    rename_column :comments, :user1_id, :user_id
  end
end
