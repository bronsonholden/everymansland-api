class ApplicationError < StandardError
  attr_reader :messages, :status

  def initialize(messages, status = :internal_server_error)
    @messages = messages
    @status = status
  end

  def inspect
    code = Rack::Utils.status_code(status)
    desc = Rack::Utils::HTTP_STATUS_CODES[code]
    text = Array.wrap(messages).to_sentence
    "#<ApplicationError: (#{code} #{desc}): #{text}>"
  end
end
