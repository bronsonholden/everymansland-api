class ApplicationError < StandardError
  attr_reader :message

  def initialize(message)
    @message = message
  end

  def status
    :internal_server_error
  end
end
