class AddStationFileName < ActiveRecord::Migration
  def up
  	change_table "playlists", :force => true do |t|
  	  t.string :station_name_image_file_name
      t.integer :station_name_image_file_size
      t.string :station_name_image_content_type
      t.timestamp :station_name_image_updated_at
  	end
  end

  def down
  end
end
