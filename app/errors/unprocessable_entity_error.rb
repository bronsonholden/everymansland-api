class UnprocessableEntityError < ApplicationError
  def self.invalid_parameter(name, expectation)
    new("Parameter #{name} #{expectation}")
  end

  def self.parameter_type_error(name, expected_type)
    self.invalid_parameter(name, "must be a #{expected_type.to_s.downcase}")
  end

  def self.parameter_enum_error(name, enum)
    self.invalid_parameter(name, "must be one of #{enum.join(", ")}")
  end

  def self.parameter_range_error(name, range)
    str = if range.begin && range.end
      "between #{range.begin} and #{range.end} inclusively"
    elsif range.begin && !range.end
      "greater than or equal to #{range.begin}"
    elsif !range.begin && range.end
      "less than or equal to #{range.end}"
    end

    self.invalid_parameter(name, "must be #{str}")
  end

  def self.parameter_missing_error(name)
    self.invalid_parameter(name, "is required")
  end

  def self.from_record_invalid(error)
    new(error.record.errors.attribute_names.map do |attribute|
      error.record.errors.messages_for(attribute).map do |message|
        "attribute '#{attribute}' #{message}"
      end
    end.flatten)
  end
end
