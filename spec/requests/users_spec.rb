describe User, type: :request do
  let(:jwt) { AccessToken::Encode.perform(user) }
  let(:headers) do
    {"Authorization" => "Bearer #{jwt}"}
  end
  let(:avatar64) { Rack::Test::UploadedFile.new("spec/fixtures/avatar64.jpeg") }
  let(:avatar512) { Rack::Test::UploadedFile.new("spec/fixtures/avatar512.jpeg") }

  describe "#upload_avatar" do
    subject { patch user_avatar_path, params: {avatar: avatar}, headers: headers }

    let(:user) { create :user, avatar: nil }
    let(:avatar) { avatar512 }

    it "uploads new avatar" do
      subject
      expect(response).to be_successful
    end

    context "with too-small file" do
      let(:avatar) { avatar64 }

      it "does not upload new avatar" do
        expect { subject }.to raise_error(ActiveRecord::RecordInvalid)
        expect(user.reload.avatar).to be_nil
      end
    end
  end

  describe "#download_avatar" do
    let(:user) { create :user }

    subject { get user_avatar_path, headers: headers }

    it "retrieves avatar" do
      subject
      expect(response).to be_successful
      expect(response.content_type).to eq("image/jpeg")
    end
  end
end
