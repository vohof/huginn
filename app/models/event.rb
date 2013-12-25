require 'json_with_indifferent_access'

class Event < ActiveRecord::Base
  attr_accessible :lat, :lng, :payload, :user_id, :user, :expires_at

  acts_as_mappable

  belongs_to :user
  belongs_to :agent, :counter_cache => true
  has_one :json_payload, :autosave => true, :as => :associate, :dependent => :delete

  def payload
    (json_payload ? json_payload : build_json_payload).payload
  end

  def payload=(p)
    (json_payload ? json_payload : build_json_payload).payload = p
  end

  validates_associated :json_payload

  scope :recent, lambda { |timespan = 12.hours.ago|
    where("events.created_at > ?", timespan)
  }

  def reemit!
    agent.create_event :payload => payload, :lat => lat, :lng => lng
  end

  def self.cleanup_expired!
    Event.where("expires_at IS NOT NULL AND expires_at < ?", Time.now).delete_all
  end
end
