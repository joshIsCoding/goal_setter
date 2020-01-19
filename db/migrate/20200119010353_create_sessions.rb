class CreateSessions < ActiveRecord::Migration[6.0]
  def change
    create_table :sessions do |t|
      t.string :session_token, null: false
      t.references :user, null: false, foreign_key: true
      t.string :remote_ip
      t.string :user_agent

      t.timestamps
    end
    add_index :sessions, :session_token, unique: true
  end
end
