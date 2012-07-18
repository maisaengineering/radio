class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.integer :user1_id
      t.integer :user2_id
      t.string :subject
      t.text :message

      t.timestamps
    end
  end
end
