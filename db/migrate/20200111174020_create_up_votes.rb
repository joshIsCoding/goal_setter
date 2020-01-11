class CreateUpVotes < ActiveRecord::Migration[6.0]
  def change
    create_table :up_votes do |t|
      t.references :user, null: false, foreign_key: true
      t.references :goal, null: false, foreign_key: true

      t.timestamps
    end
    add_index :up_votes, [:user_id, :goal_id], unique: true
  end
end
