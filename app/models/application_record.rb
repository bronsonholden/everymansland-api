class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  class ApplicationError < StandardError
    attr_reader :message
    def initialize(message)
      @message = message
    end
  end
end
