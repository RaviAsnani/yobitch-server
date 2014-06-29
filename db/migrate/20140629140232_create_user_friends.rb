class CreateUserFriends < ActiveRecord::Migration
  def change
    create_table :user_friends do |t|
      t.integer :user_id, index: true
      t.integer :friend_id, index: true

      t.timestamps
    end
  end
end
