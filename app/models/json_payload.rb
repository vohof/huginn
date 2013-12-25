class JsonPayload < ActiveRecord::Base
  attr_accessible :associate_id, :associate_type, :payload, :associate

  belongs_to :associate, :polymorphic => true

  serialize :payload, JSONWithIndifferentAccess

  def payload=(o)
    self[:payload] = ActiveSupport::HashWithIndifferentAccess.new(o)
  end
end
