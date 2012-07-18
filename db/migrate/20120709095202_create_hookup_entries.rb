class CreateHookupEntries < ActiveRecord::Migration
  def change
    create_table :hookup_entries do |t|
      t.string :user_id
      t.string :entry_type
      t.timestamps
    end
  end
end
