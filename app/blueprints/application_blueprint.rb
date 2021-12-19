class ApplicationBlueprint < Blueprinter::Base
  def self.url(path)
    "#{Rails.application.routes.default_url_options[:protocol]}://#{Rails.application.routes.default_url_options[:host]}/#{path}"
  end

  class << self
    # Hack so we don't have to symbolize view names every time
    %i[render render_as_hash render_as_json].each do |method|
      define_method method do |*args, **opts|
        opts[:view] &&= opts[:view].to_sym
        super(*args, **opts)
      end
    end
  end

  # For nested objects
  view :anonymous do
    exclude :id
  end
end
