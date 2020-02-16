require 'active_support/concern'

module Eventable
  extend ActiveSupport::Concern

  included do
    has_many :key_events, as: :eventable, dependent: :destroy
  end

  def asset_owner
    self.user
  end

  private

  def generate_event(event_type)
    self.key_events << KeyEvent.create(
      eventable: self,
      event_type: event_type,
      instigator: self.asset_owner
    )
  end
end

