class CreateCommentOnActivities < ActiveRecord::Migration
  def change
    create_table :comment_on_activities do |t|
      t.string :comment_id
      t.string :favorite_id
      t.string :user_id
      t.string :activity_comment
      t.timestamps
    end
  end
end
