class CreateNotifications < ActiveRecord::Migration[6.0]
  def change
    create_table :notifications do |t|
      t.references :user, null: false, foreign_key: true
      t.references :key_event, null: false, foreign_key: true
      t.boolean :seen, default: false

      t.timestamps
    end
    add_index :notifications, [:key_event_id, :user_id], unique: true
  end
end
