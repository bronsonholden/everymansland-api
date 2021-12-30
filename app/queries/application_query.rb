# Queries encapsulate business logic and access policies. There are two forms
# of input for queries: parameters (usually called params) and context. Both
# params and context must be declared by each query using the #param and
# #context class methods respectively. Undeclared values will not be used
# during resolution. Declared params and context values are validated using
# the Parameter::Validate service.
#
# The pattern suits index requests that may behave differently depending on
# what endpoint is being called, or whether there is an authenticated user,
# but nothing dictates what #resolve does once it has its validated context
# and params...
#
# Queries are tightly coupled with ActiveRecord, but the inputs are hashes
# and there's no paging applied to keep them decoupled from controllers,
# making them more easily tested and more portable.
class ApplicationQuery
  class << self
    attr_accessor :declared_params, :declared_context
  end

  def initialize(params, context)
    @params = params || {}
    @context = context || {}
  end

  def self.exec(params, context)
    new(params, context).exec
  end

  def self.param(name, type, options = {})
    (self.declared_params ||= []) << {name: name, type: type, options: options}
  end

  def self.context(name, type, options = {})
    (self.declared_context ||= []) << {name: name, type: type, options: options}
  end

  def exec
    resolve(params!, context!)
  end

  protected

  def resolve
    raise NoMethodError
  end

  private

  def params!
    result = @params.slice(*self.class.declared_params.map { |param| param[:name] })
    self.class.declared_params.each do |param|
      Parameter::Validate.perform(result, param[:name], param[:type], param[:options])
    end
    result
  end

  def context!
    result = @context.slice(*self.class.declared_context.map { |param| param[:name] })
    self.class.declared_context.each do |ctx|
      Parameter::Validate.perform(result, ctx[:name], ctx[:type], ctx[:options])
    end
    result
  rescue UnprocessableEntityError => e
    fail ApplicationError.new("Invalid query context provided: #{e.message}")
  end
end
