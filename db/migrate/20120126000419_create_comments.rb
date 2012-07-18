class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.integer :song_id
      t.text :comment
      t.integer :user1_id
      t.integer :parent_id

      t.timestamps
    end
  end
end
