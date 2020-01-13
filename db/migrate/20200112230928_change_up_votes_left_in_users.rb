class ChangeUpVotesLeftInUsers < ActiveRecord::Migration[6.0]
  def change
    change_column_null :users, :up_votes_left, true
    change_column_default :users, :up_votes_left, nil
  end
end
