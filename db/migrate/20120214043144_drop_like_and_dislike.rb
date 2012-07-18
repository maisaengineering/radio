class DropLikeAndDislike < ActiveRecord::Migration
  def up
  	drop_table :likes
  	drop_table :dislikes
  end

  def down
  end
end
