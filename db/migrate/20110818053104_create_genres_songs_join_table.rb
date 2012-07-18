class CreateGenresSongsJoinTable < ActiveRecord::Migration
  def up
    create_table :genres_songs, :id => false do |t|
      t.integer :genre_id
      t.integer :song_id
    end
  end

  def down
    drop_table :genres_songs
  end
end
