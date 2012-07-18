class AddUsernames < ActiveRecord::Migration
  def up
    User.all.each do |u|
      u.update_attribute(:username, u.email.split('@')[0])
    end
  end

  def down
  end
end
