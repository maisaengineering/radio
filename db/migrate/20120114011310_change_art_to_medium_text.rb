class ChangeArtToMediumText < ActiveRecord::Migration
  def up
  	remove_column :albums, :art
  	add_column :albums, :art, :mediumtext
  end

  def down
  end
end
