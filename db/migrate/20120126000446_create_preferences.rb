class CreatePreferences < ActiveRecord::Migration
  def change
    create_table :preferences do |t|
      t.string :type
      t.string :setting
      t.integer :user_id

      t.timestamps
    end
  end
end
