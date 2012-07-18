class CreateSongs < ActiveRecord::Migration
  def change
    create_table :songs do |t|

      # paperclip
      t.string :audio_file_name
      t.integer :audio_file_size
      t.string :audio_content_type
      t.timestamp :audio_updated_at

      t.string :title
      t.integer :artist_id
      t.integer :uploader_id
      t.string :explanation
      t.integer :length_in_seconds #save
      t.string :where_to_download # Perhaps a link to a music provider (itunes, etc)
      t.integer :ish_rating
      t.text :lyrics
      t.boolean :can_download

      t.timestamps
    end
  end
end
