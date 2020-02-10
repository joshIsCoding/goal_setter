class RemoveGoalIdCategories < ActiveRecord::Migration[6.0]
  def change
    remove_column :categories, :goals_id, :bigint
  end
end
