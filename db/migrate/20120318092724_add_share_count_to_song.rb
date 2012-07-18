class AddShareCountToSong < ActiveRecord::Migration
  def change
    add_column :songs, :share_count, :integer
  end
end
