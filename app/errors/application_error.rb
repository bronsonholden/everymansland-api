class ApplicationError < StandardError
  attr_reader :messages, :code

  def initialize(messages)
    @messages = messages
  end

  def inspect
    code = Rack::Utils.status_code(status)
    desc = Rack::Utils::HTTP_STATUS_CODES[code]
    text = Array.wrap(messages).to_sentence
    "#<#{self.class}: (#{code} #{desc}): #{text}>"
  end

  def status
    return :internal_server_error if instance_of?(ApplicationError)
    self.class.name.gsub(/Error\z/, "").underscore.to_sym
  end
end
