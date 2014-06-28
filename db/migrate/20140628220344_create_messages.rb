class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.references :user, index: true
      t.string :abuse
      t.string :sensored_abuse

      t.timestamps
    end
  end
end
