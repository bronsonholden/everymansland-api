class NotFoundError < ApplicationError
  def self.with(klass, attribute, value)
    new("#{klass.to_s.humanize} with #{attribute} #{value} not found")
  end
end
