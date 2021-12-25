class ConvertAltitudesFromKmToM < ActiveRecord::Migration[6.1]
  def change
    add_column :snapshots, :altitude2, :integer

    Snapshot.where.not(altitude: nil).in_batches do |snapshots|
      snapshots.each do |snapshot|
        snapshot.update(altitude2: snapshot.altitude * 1000)
      end
    end

    remove_column :snapshots, :altitude
    rename_column :snapshots, :altitude2, :altitude
  end
end
