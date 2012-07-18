class CreateRecommendations < ActiveRecord::Migration
  def change
    create_table :recommendations do |t|
      t.integer :user1_id
      t.integer :user2_id
      t.integer :song_id

      t.timestamps
    end
  end
end
