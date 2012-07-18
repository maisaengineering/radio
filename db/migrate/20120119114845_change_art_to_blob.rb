class ChangeArtToBlob < ActiveRecord::Migration
  def up
  	#remove_column :albums, :art
  	#add_column :albums, :art, :blob
  end

  def down
  end
end
