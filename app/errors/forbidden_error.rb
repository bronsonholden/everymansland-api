class ForbiddenError < ApplicationError
  def self.no_permission(to_do)
    new("You do not have permission to #{to_do}")
  end

  def self.no_show_permission(record)
    self.no_permission("view this #{record.class.name.downcase}")
  end

  def self.no_update_permission(record)
    self.no_permission("change this #{record.class.name.downcase}")
  end

  def self.no_destroy_permission(record)
    self.no_permission("delete this #{record.class.name.downcase}")
  end
end
