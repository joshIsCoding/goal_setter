class AddCityToSessions < ActiveRecord::Migration[6.0]
  def change
    add_column :sessions, :city, :string
  end
end
