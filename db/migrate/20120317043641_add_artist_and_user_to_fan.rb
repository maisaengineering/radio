class AddArtistAndUserToFan < ActiveRecord::Migration
  def change
    rename_column :fans, :user1_id, :artist_id
    rename_column :fans, :user2_id, :user_id
  end
end
