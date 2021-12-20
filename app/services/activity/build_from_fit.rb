class Activity::BuildFromFit < ApplicationService
  attr_reader :activity

  def initialize(io)
    @io = io
    @activity = Activity.new(started_at: Time.now)
    @records = []
  end

  def perform
    parser = RubyFit::FitParser.new(self)
    parser.parse(@io)

    generate_power_curve([
      1.second,
      2.seconds,
      5.seconds,
      10.seconds,
      20.seconds,
      30.seconds,
      1.minute,
      2.minutes,
      5.minutes,
      10.minutes,
      20.minutes,
      30.minutes,
      1.hour,
      2.hours,
      3.hours,
      4.hours,
      5.hours,
      6.hours
    ])

    Activity.transaction do
      now = Time.now
      @activity.save!
      @records = @records.map do |record|
        record.merge({
          t: (record[:timestamp] - @activity.started_at).to_i,
          activity_id: @activity.id,
          created_at: now,
          updated_at: now
        })
      end

      Snapshot.insert_all(@records)
    end

    @activity
  end

  def print_msg(msg)
  end

  def print_error_msg(msg)
  end

  def on_activity(msg)
  end

  def on_lap(msg)
  end

  def on_session(msg)
    @activity.started_at = Time.at(msg["start_time"])
    @activity.sport = msg["sport"]
  end

  def on_record(msg)
    payload = {
      timestamp: Time.at(msg["timestamp"]),
      raw_data: msg,
      rider_position: @rider_position,
      power: msg["power"],
      altitude: msg.fetch_by("altitude", &:m), # meters above sealevel
      cumulative_distance: msg.fetch_by("distance", &:m), # meters
      heart_rate: msg["heart_rate"],
      speed: msg["speed"] * 3.6, # meters per second
      cadence: msg["cadence"],
      temperature: msg["temperature"]
    }

    # If both latitude and longitude are present
    if (%w[position_lat position_long] - msg.keys).empty?
      payload[:location] = "POINT(#{msg["position_long"]} #{msg["position_lat"]})"
    end

    @records << payload
  end

  def on_event(msg)
    case msg["event"]
    when 44 # rider_position_change
      on_rider_position_change(msg)
    end
  end

  def on_device_info(msg)
  end

  def on_user_profile(msg)
    payload = {
      weight: msg["weight"]
    }

    @activity.condition = Condition.new(payload)
  end

  def on_weight_scale_info(msg)
  end

  private

  def on_rider_position_change(msg)
    case msg["data"]
    when 0 # seated
      @rider_position = :seated
    when 1 # standing
      @rider_position = :standing
    end
  end

  def generate_power_curve(steps)
    profile = @records.map do |record|
      {
        t: (record[:timestamp] - @activity.started_at).to_i,
        power: record[:power] || 0
      }
    end

    profile.inject(0) do |t, moment|
      moment[:dt] = moment[:t] - t
      moment[:t]
    end

    peaks = Hash.new
    steps.each do |t|
      peaks[t] = get_power_peaks(t, profile)
    end

    @activity.critical_power = peaks.compact.to_a
  end

  # Walk through the power profile, getting average power for all ranges
  # that match the given duration. The timestamp resolution for FIT files is
  # seconds, so we can check for exact duration. Whenever the range is
  # greater than the duration (due perhaps to gaps in record data, or more
  # likely a pause in the activity), we walk the left edge up until the
  # range's duration is below the target duration
  def get_power_peaks(duration, profile)
    return nil if profile.last[:t] < duration
    return profile.map { |p| p[:power] }.max if duration == 1

    right = 1
    t = 0
    left = 0
    max = 0
    power = 0

    while right < profile.size
      current = profile[right]
      t += current[:dt]
      power += current[:power]
      while t > duration
        t -= profile[left][:dt]
        power -= profile[left][:power]
        left += 1
      end
      if t == duration
        avg = power.to_f / (right - left + 1)
        if avg > max
          max = avg
        end
      end
      right += 1
    end

    max.ceil
  end
end
