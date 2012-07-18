class RenamePlayOrder < ActiveRecord::Migration
  def up
    rename_column :songs, :play_order, :position
  end

  def down
  end
end
