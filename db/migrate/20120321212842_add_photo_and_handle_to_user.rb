class AddPhotoAndHandleToUser < ActiveRecord::Migration
  def change
      add_column :users, :handle, :string
      add_column :users, :photo_file_name, :string
      add_column :users,  :photo_file_size, :integer
      add_column :users, :photo_updated_at, :timestamp
  end
end
