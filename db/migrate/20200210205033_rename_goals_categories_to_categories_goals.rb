class RenameGoalsCategoriesToCategoriesGoals < ActiveRecord::Migration[6.0]
  def change
    rename_table :goals_categories, :categories_goals
  end
end
