class AddBrowserAndDeviceToSessions < ActiveRecord::Migration[6.0]
  def change
    add_column :sessions, :browser, :string
    add_column :sessions, :device, :string
  end
end
