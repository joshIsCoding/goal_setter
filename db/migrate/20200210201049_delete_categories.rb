class DeleteCategories < ActiveRecord::Migration[6.0]
  def change
    drop_table :categories do |t|
      t.string :name
      t.references :goals, null: false, foreign_key: true
    end
  end
end
