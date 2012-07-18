class AddAlbumArtFields < ActiveRecord::Migration
  def up
  	  add_column :albums, :art_file_name, :string
      add_column :albums,  :art_file_size, :integer
      add_column :albums, :art_updated_at, :timestamp
  end

  def down
  	  remove_column :albums, :art_file_name
      remove_column :albums,  :art_file_size
      remove_column :albums,  :art_content_type
      remove_column :albums, :art_updated_at
  end
end
