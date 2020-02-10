class CreateGoalCategories < ActiveRecord::Migration[6.0]
  def change
    create_table :categories do |t|
      t.string :name, null: false
      t.timestamps
    end

    create_table :goals_categories do |t|
      t.belongs_to :category
      t.belongs_to :goal
    end
  end
end
