class KeyEvent < ApplicationRecord
  validates_inclusion_of :type, in: ["new", "update"]
  belongs_to :eventable, polymorphic: true
  belongs_to :instigator, class_name: "User"
end
