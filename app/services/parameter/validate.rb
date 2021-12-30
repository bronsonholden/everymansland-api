class Parameter::Validate < ApplicationService
  attr_reader :params, :name, :type, :options

  def initialize(params, name, type, options)
    @params = params
    @name = name
    @type = type
    @options = options
  end

  def perform
    params[name] = params[name].to_s if params[name].is_a?(Symbol)
    params[name] ||= options[:default] if options[:default]

    if options[:required]
      raise UnprocessableEntityError.parameter_missing_error(name) unless params[name].present?
    end

    return unless params[name].present?

    if type == Integer
      begin
        params[name] = Integer(params[name], 10)
      rescue ArgumentError, TypeError
        # Will raise below
      end
    end

    raise UnprocessableEntityError.parameter_type_error(name, type) if !params[name].is_a?(type)

    if options[:in]
      raise UnprocessableEntityError.parameter_enum_error(name, options[:in]) unless options[:in].include?(params[name])
    elsif options[:range]
      raise UnprocessableEntityError.parameter_range_error(name, options[:range]) unless options[:range].cover?(params[name])
    end
  end
end
