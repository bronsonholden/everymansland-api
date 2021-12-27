class ActiveRecord::Associations::CollectionProxy
  # Fixes what feels like a bug with CollectionProxy. Bang query methods
  # don't behave.
  def records
    all
  end
end
