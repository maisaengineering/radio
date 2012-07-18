class CreateHeardIts < ActiveRecord::Migration
  def change
    create_table :heard_its do |t|
      t.integer :song_id
      t.integer :user_id
      t.boolean :heard_it

      t.timestamps
    end
  end
end
