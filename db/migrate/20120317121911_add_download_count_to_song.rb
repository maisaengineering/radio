class AddDownloadCountToSong < ActiveRecord::Migration
  def change
    add_column :songs, :download_count, :integer
  end
end
