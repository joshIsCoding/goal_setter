class ChangeUpVotesLeftNullToFalse < ActiveRecord::Migration[6.0]
  def change
    change_column_null :users, :up_votes_left, false
  end
end
