class ApplicationError < StandardError
  attr_reader :messages, :code

  def initialize(messages)
    @messages = messages
  end

  def inspect
    "#<#{self.class}: #{to_s}>"
  end

  def status
    return :internal_server_error if instance_of?(ApplicationError)
    self.class.name.gsub(/Error\z/, "").underscore.to_sym
  end

  def to_s
    Array.wrap(messages.map(&:uncapitalize)).to_sentence.capitalize
  end
end
