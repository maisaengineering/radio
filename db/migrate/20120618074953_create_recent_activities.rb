class CreateRecentActivities < ActiveRecord::Migration
  def change
    create_table :recent_activities do |t|
      t.string :activity_type
      t.string :user_id
      t.string :song_id
      t.string :activity
      t.timestamps
    end
  end
end
