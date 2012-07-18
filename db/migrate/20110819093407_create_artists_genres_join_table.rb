class CreateArtistsGenresJoinTable < ActiveRecord::Migration
  def up
    create_table :artists_genres, :id => false do |t|
      t.integer :artist_id
      t.integer :genre_id
    end
  end

  def down
    drop_table :artists_genres
  end
end
