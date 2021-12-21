describe PowerCurve::Calculate do
  subject { described_class.perform(profile, Array.wrap(duration)) }

  # Helper to create power profiles. Yields time offset `t` to block, if
  # given. Otherwise, uses `power` argument to generate a constant profile.
  # Passing `nil` for `power` excludes the reading, to create gaps in the
  # power profile.
  def generate_power_profile(duration, power = 0, &block)
    Array.new(duration) do |t|
      power = block_given? ? yield(t + 1) : power
      {t: t + 1, power: power} unless power.nil?
    end.compact.unshift({t: 0, power: 0})
  end

  context "constant profile" do
    let(:duration) { 1.hour }
    let(:profile) {
      generate_power_profile(duration, 100)
    }
    it { is_expected.to include([1.hour, 100]) }
  end

  context "mixed profile" do
    let(:duration) { [30.minutes, 1.hour] }
    let(:profile) {
      generate_power_profile(1.hour) do |t|
        t <= 30.minutes ? 100 : 200
      end
    }
    it { is_expected.to include([1.hour, 150], [30.minutes, 200]) }
  end

  context "profile with pause" do
    let(:duration) { [1.hour, 20.minutes, 30.minutes] }
    let(:profile) {
      generate_power_profile(1.hour) do |t|
        t >= 20.minutes && t < 40.minutes ? nil : 180
      end
    }

    # 30 minute power should be 120 (20 minutes at 180, 10 at zero)
    it { is_expected.to include([1.hour, 120], [20.minutes, 180], [30.minutes, 120]) }
  end

  # Bit of an edge case, but you never know
  context "starting gap" do
    let(:duration) { 3.seconds }
    let(:profile) {
      generate_power_profile(3.seconds, 300).reject { |reading| reading[:t] == 1 }
    }

    it { is_expected.to include([3.seconds, 200]) }
  end
end
