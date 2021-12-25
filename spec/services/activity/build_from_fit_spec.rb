describe Activity::BuildFromFit do
  let(:io) { IO.read(Rails.root.join("spec/fixtures", "activity.fit")) }
  let!(:user) { create :user } # creates Condition; do so outside of test
  it "creates records" do
    expect { described_class.perform(user, io) }
      .to change { Snapshot.count }
      .and change { Activity.count }.by(1)
      .and change { Condition.count }.by(1)
  end
end
