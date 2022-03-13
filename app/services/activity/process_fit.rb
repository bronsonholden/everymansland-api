class Activity::ProcessFit < ApplicationService
  attr_reader :activity

  def initialize(activity)
    @io = activity.fit.download.read
    @activity = activity
    @records = []
  end

  def perform
    parser = RubyFit::FitParser.new(self)
    parser.parse(@io)

    power_profile = @records.map do |record|
      {
        t: (record[:timestamp] - @activity.started_at).to_i,
        power: record[:power] || 0
      }
    end

    @activity.power_curve = PowerCurve::Calculate.perform(power_profile, [
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
    @activity.state = :processed
    @activity.distance = msg.fetch_by("total_distance", &:m)
    @activity.elevation_gain = msg["total_ascent"]
    @activity.elevation_loss = msg["total_descent"]
    @activity.calories_burned = msg["total_calories"]
    @activity.average_speed = msg["avg_speed"] * 3.6
    @activity.max_speed = msg["max_speed"] * 3.6
    @activity.average_power = msg["avg_power"]
    @activity.max_power = msg["max_power"]
    @activity.average_heart_rate = msg["avg_heart_rate"]
    @activity.max_heart_rate = msg["max_heart_rate"]
    @activity.average_cadence = msg["avg_cadence"]
    @activity.max_cadence = msg["max_cadence"]
    @activity.elapsed_time = msg["total_elapsed_time"].floor
    @activity.moving_time = msg["total_timer_time"].floor
    @activity.cycling_normalized_power = msg["normalized_power"]
    @activity.cycling_training_stress_score = msg["training_stress_score"]
    @activity.cycling_intensity_factor = msg["intensity_factor"]
  end

  def on_record(msg)
    payload = {
      timestamp: Time.at(msg["timestamp"]),
      raw_data: msg,
      rider_position: @rider_position,
      power: msg["power"],
      altitude: msg["altitude"],
      cumulative_distance: msg.fetch_by("distance", &:m), # meters
      heart_rate: msg["heart_rate"],
      speed: msg["speed"].present? ? msg["speed"] * 3.6 : nil, # meters per second
      cadence: msg["cadence"],
      temperature: msg["temperature"],
      location: nil
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
end
