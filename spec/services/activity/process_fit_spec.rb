describe Activity::ProcessFit do
  let!(:user) { create :user } # creates Condition; do so outside of test
  let(:file) { Rack::Test::UploadedFile.new("spec/fixtures/activity.fit") }
  let(:activity) { create :activity, fit: file, user: user }

  subject { -> { described_class.perform(activity) } }

  it { is_expected.to change { Snapshot.count }.and change { Condition.count }.by(1) }
  it { is_expected.to change { activity.state }.from("pending").to("processed") }
end
