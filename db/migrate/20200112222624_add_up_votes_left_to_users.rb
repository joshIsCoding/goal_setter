class AddUpVotesLeftToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :up_votes_left, :integer, default: 10, null: false
  end
end
