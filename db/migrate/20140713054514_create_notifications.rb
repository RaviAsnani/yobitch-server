class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
      t.references :message, index: true
      t.integer :sender_id, index: true
      t.integer :receiver_id, index: true
      t.boolean :sent, default: false, index: true
      t.timestamps
    end
  end
end
