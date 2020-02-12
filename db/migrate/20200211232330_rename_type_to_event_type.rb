class RenameTypeToEventType < ActiveRecord::Migration[6.0]
  def change
    rename_column :key_events, :type, :event_type
  end
end
