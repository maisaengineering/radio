class DeviseCreateUsers < ActiveRecord::Migration
  def self.up
    create_table(:users) do |t|
      t.database_authenticatable :null => false
      t.recoverable
      t.rememberable
      t.trackable

      # t.encryptable
      # t.confirmable
      # t.lockable :lock_strategy => :failed_attempts, :unlock_strategy => :both
      # t.token_authenticatable
      t.string :username
      t.string :email
      t.string :zip
      t.string :address
      t.boolean :sex
      t.datetime :dob
      t.string :birthplace
      t.string :city
      t.text :bio

      t.timestamps
    end

    # Create a default user
    User.create!(:email => 'admin@example.com', :password => 'password', :password_confirmation => 'password')

    add_index :users, :email,                :unique => true
    add_index :users, :reset_password_token, :unique => true
    # add_index :users, :confirmation_token,   :unique => true
    # add_index :users, :unlock_token,         :unique => true
    # add_index :users, :authentication_token, :unique => true
  end

  def self.down
    drop_table :users
  end
end
