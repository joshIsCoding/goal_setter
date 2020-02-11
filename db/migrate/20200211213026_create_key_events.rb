class CreateKeyEvents < ActiveRecord::Migration[6.0]
  def change
    create_table :key_events do |t|
      t.references :eventable, null: false, polymorphic: true
      t.string :type, null: false
      t.references :instigator, null: false, foreign_key: {to_table: :users}
      t.boolean :notifications_generated, default: false

      t.timestamps
    end
  end
end
