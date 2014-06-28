class CreateUserContacts < ActiveRecord::Migration
  def change
    create_table :user_contacts do |t|
      t.references :user, index: true
      t.string :email

      t.timestamps
    end
    add_index :user_contacts, [:user_id, :email], unique: true
  end
end
