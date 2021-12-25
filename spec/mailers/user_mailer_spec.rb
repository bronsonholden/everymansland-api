describe UserMailer, type: :mailer do
  let(:user) { build :user, confirmation_token: "abc" }
  let(:mail) { described_class.invite(user) }

  describe "headers" do
    it "renders the subject" do
      expect(mail.subject).to eq I18n.t("user_mailer.invite.subject")
    end

    it "sends to the right email" do
      expect(mail.to).to eq [user.email]
    end

    it "renders the from email" do
      expect(mail.from).to eq ["noreply@everymansland.com"]
    end
  end

  describe "body" do
    it "includes the correct URL" do
      expect(mail.body.encoded).to include user.confirmation_url
    end
  end
end
