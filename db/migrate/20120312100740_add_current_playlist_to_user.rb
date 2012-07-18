class AddCurrentPlaylistToUser < ActiveRecord::Migration
  def up
    add_column :users, :current_playlist, :string
  end
  def down
  end
end
