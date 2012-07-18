class AddSongIdToCommentOnActivities < ActiveRecord::Migration
  def change
  	add_column :comment_on_activities, :song_id, :string
  end
end
