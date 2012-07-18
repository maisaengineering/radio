class AddColumnFbProfilePicToUsers < ActiveRecord::Migration
  def change
  	add_column :users, :fb_profile_pic, :string
  end
end
