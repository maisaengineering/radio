class CreateInitalPlayerOrderState < ActiveRecord::Migration
  def up
    all = Song.all
    all.each do |a|
      a.update_attribute(:play_order, a.id)
    end
  end

  def down
  end
end
