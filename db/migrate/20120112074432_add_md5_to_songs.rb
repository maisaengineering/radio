class AddMd5ToSongs < ActiveRecord::Migration
  def change
  	add_column :songs, :md5, :string
  end
end
