class ChangeGoalsPublicDefaultToTrue < ActiveRecord::Migration[6.0]
  def change
    change_column_default :goals, :public, from: false, to: true
  end
end
