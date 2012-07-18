class AddArtContentTypeToAlbum < ActiveRecord::Migration
  def change
  	add_column :albums, :art_content_type, :string
  end
end
