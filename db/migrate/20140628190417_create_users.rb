class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users  do |t|
      t.timestamps null: false
      t.string :email, null: false
      t.string :name
      t.boolean :is_free, default: true
      t.boolean :is_elevated, default: false
      t.string :gcm_token
      t.string :auth_token
      t.string :encrypted_password, limit: 128, null: false
      t.string :confirmation_token, limit: 128
      t.string :remember_token, limit: 128, null: false
    end

    add_index :users, :email
    add_index :users, :auth_token
  end

  def self.down
    drop_table :users
  end
end
