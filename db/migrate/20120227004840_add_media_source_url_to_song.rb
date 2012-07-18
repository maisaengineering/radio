class AddMediaSourceUrlToSong < ActiveRecord::Migration
  def up
  	add_column :songs, :media_source_url, :string
  end
  def down
  end
end
