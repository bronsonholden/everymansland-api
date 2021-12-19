class Hash
  # Nifty little helper for fetching & mutating values in a hash if present
  def fetch_by(key, &block)
    v = fetch(key, nil)
    yield v unless v.nil?
  end
end
