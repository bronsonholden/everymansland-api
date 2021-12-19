describe Activity::BuildFromFit do
  let(:io) { IO.read(Rails.root.join("spec/fixtures", "activity.fit")) }
  it "creates records" do
    expect { described_class.perform(io) }
      .to change { Snapshot.count }
      .and change { Activity.count }.by(1)
      .and change { Condition.count }.by(1)
  end
end
