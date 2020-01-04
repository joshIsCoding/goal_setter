class ChangePublicDefaults < ActiveRecord::Migration[6.0]
  def change
    change_column_default :goals, :public, false
    change_column_null :goals, :public, false
  end
end
