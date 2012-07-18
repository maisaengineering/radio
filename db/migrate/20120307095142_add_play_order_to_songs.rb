class AddPlayOrderToSongs < ActiveRecord::Migration
  def up
    add_column :songs, :play_order, :integer
    add_index :songs, :play_order
  end
  def down
  end
end
