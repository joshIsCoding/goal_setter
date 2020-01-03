class ChangeStatusDefault < ActiveRecord::Migration[6.0]
  def change
    change_column_default :goals, :status, "Not Started"
  end
end
