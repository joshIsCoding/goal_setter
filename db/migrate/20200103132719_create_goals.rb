class CreateGoals < ActiveRecord::Migration[6.0]
  def change
    create_table :goals do |t|
      t.string :title, null: false
      t.text :details
      t.string :status, null: false
      t.boolean :public?
      t.integer :user_id, null: false

      t.timestamps
    end
    add_index :goals, [:user_id, :title], unique: true
  end
end
