class AddDownloadLink < ActiveRecord::Migration
  def up
  	add_column :songs, :download_link, :string
  end

  def down
  	# pubic
  end
end
