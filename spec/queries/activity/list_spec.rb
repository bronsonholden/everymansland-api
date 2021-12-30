describe Activity::List do
  subject { described_class.exec(params, context) }
  let(:params) { Hash.new }
  let(:user) { create :user }
  let!(:published_activity) { create :activity, :published, user: user }
  let!(:shared_activity) { create :activity, :shared, user: user }
  let!(:hidden_activity) { create :activity, :hidden, user: user }

  context "user for self" do
    let(:context) do
      {
        requesting_user: user,
        for_user: user
      }
    end

    it { is_expected.to contain_exactly(published_activity, shared_activity, hidden_activity) }
  end

  context "user for friend" do
    let(:friend) { create :user }
    let(:context) do
      {
        requesting_user: friend,
        for_user: user
      }
    end

    before(:each) do
      assert Friendship.makeup(user, friend)
    end

    it { is_expected.to contain_exactly(published_activity, shared_activity) }
  end

  context "user for user" do
    let(:other_user) { create :user }
    let(:context) do
      {
        requesting_user: other_user,
        for_user: user
      }
    end

    it { is_expected.to contain_exactly(published_activity) }
  end

  context "user for anyone" do
    let(:other_user) { create :user }
    let(:context) do
      {
        requesting_user: other_user,
        for_user: nil
      }
    end

    it { is_expected.to contain_exactly(published_activity) }
  end

  context "anonymous for user" do
    let(:context) do
      {
        requesting_user: nil,
        for_user: user
      }
    end

    it { is_expected.to contain_exactly(published_activity) }
  end

  context "anonymous for anyone" do
    let(:context) do
      {
        requesting_user: nil,
        for_user: nil
      }
    end

    it { is_expected.to contain_exactly(published_activity) }
  end
end
