class CreateCommentLikes < ActiveRecord::Migration
  def change
    create_table :comment_likes do |t|
      t.string :comment_id
      t.string :favorite_id
      t.string :user_id
      t.timestamps
    end
  end
end
