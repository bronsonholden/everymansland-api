class SnapshotBlueprint < ApplicationBlueprint
  identifier :id

  field :t
  field :timestamp

  view :outdoors do
    field :altitude
    field :location do |snapshot|
      RGeo::GeoJSON.encode(snapshot.location)
    end
    field :temperature
  end

  view :cycling do
    include_view :outdoors
    field :cadence
    field :heart_rate
    field :power
    field :cumulative_distance
  end
end
