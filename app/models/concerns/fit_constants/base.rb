module FitConstants::Base
  def [](attr = self.name.split("::").last.to_s.underscore)
    ::Module.new do
      extend ActiveSupport::Concern
      included do
        enum :"#{attr}" => @@values
      end
    end
  end

  def values(values)
    @@values = values
  end
end
