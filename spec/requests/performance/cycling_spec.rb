describe "Performance::Cycling", type: :request do
  let(:user) { create :user }
  let(:jwt) { AccessToken::Encode.perform(user) }
  let(:headers) do
    {"Authorization" => "Bearer #{jwt}"}
  end

  describe "activity history" do
    let(:params) { {} }
    subject { get activities_performance_cycling_path, params: params, headers: headers }

    before(:each) do
      create(
        :activity,
        user: user
      )
      create(
        :activity,
        user: user,
        started_at: Time.now - 1.day
      )
    end

    it "returns activity stats" do
      subject
      expect(response).to be_successful
      expect(response_json).to be_an(Array)
      expect(response_json.size).to eq 1
      data = response_json.first
      expect(data.fetch("count")).to eq Activity.all.count
      expect(data.fetch("distance")).to eq Activity.all.pluck(:distance).sum
      expect(data.fetch("calories_burned")).to eq Activity.all.pluck(:calories_burned).sum
    end
  end

  xdescribe "power curve" do
  end

  xdescribe "critical power" do
  end
end
