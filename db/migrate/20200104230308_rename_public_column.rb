class RenamePublicColumn < ActiveRecord::Migration[6.0]
  def change
    rename_column :goals, :public?, :public
  end
end
