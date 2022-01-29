class NotFoundError < ApplicationError
  def self.record_with_attribute_value(klass, attribute, value)
    self.looked_for("#{klass.to_s.humanize} with #{attribute} #{value}")
  end

  def self.looked_for(thing)
    new("#{thing} not found")
  end
end
