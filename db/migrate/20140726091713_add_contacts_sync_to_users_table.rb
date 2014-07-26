class AddContactsSyncToUsersTable < ActiveRecord::Migration
  def change
    add_column :users, :contact_sync, :boolean, default: false
  end
end
