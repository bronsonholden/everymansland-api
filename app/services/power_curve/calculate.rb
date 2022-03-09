# Calculate a power curve given a power profile as an array of hashes
# including `t` (time in seconds from activity start) and `power` (power meter
# reading at time `t`)
class PowerCurve::Calculate < ApplicationService
  def initialize(profile, durations)
    @durations = durations
    # Calculation is simpler if we have timestep from last reading
    @profile = profile.dup
    @profile.unshift({t: 0, power: 0}) unless @profile.first[:t].zero?
    @profile.inject(0) do |t, moment|
      moment[:dt] = moment[:t] - t
      moment[:t]
    end
  end

  def perform
    @durations.sort.map do |duration|
      critical_power = get_critical_power(duration)
      [duration, critical_power] unless critical_power.nil?
    end.compact
  end

  private

  # Walk through the power profile, getting average power for all ranges
  # that match the given duration. The timestamp resolution for FIT files is
  # seconds, so we can check for exact duration. Whenever the range is
  # greater than the duration (due perhaps to gaps in record data, or more
  # likely a pause in the activity), we walk the left edge up until the
  # range's duration is below the target duration
  def get_critical_power(duration)
    return nil if @profile.last[:t] < duration
    return @profile.map { |p| p[:power] }.max if duration == 1

    right = 1
    t = 0
    left = 1
    max = 0
    power = 0

    while right < @profile.size
      current = @profile[right]
      peek = @profile[right + 1]

      # Do a power calculation before overshooting duration & walking the
      # left edge back up
      if peek.present? && t + peek[:dt] > duration
        avg = power.to_f / duration
        if avg > max
          max = avg
        end
      end

      t += current[:dt]
      power += current[:power]

      while t > duration
        t -= @profile[left][:dt]
        power -= @profile[left][:power]
        left += 1
        avg = power.to_f / duration
        if t <= duration && avg > max
          max = avg
        end
      end
      right += 1
    end

    avg = power.to_f / duration
    if t <= duration && avg > max
      max = avg
    end

    max.round
  end
end
