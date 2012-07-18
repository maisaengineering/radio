class AddSongIdToCommentLikes < ActiveRecord::Migration
  def change
  	add_column :comment_likes, :song_id, :string
  end
end
