# Conversions are monkeypatched for simplicity and code readability. Be
# careful when chain calling these...

LBS_PER_KG = 2.20462
MI_PER_KM = 0.621371
YD_PER_MI = 1760
FT_PER_YD = 3
KJ_PER_KCAL = 4.184
CUP_PER_L = 4.22675

class Numeric
  def to_lbs
    self * LBS_PER_KG
  end

  def to_mi
    self * MI_PER_KM
  end
  alias to_mph to_mi

  def to_yd
    self * MI_PER_KM * YD_PER_MI
  end

  def to_ft
    to_yd * FT_PER_YD
  end

  def to_kJ
    self * KJ_PER_KCAL
  end

  def to_F
    (self * (9.0 / 5)) + 32
  end

  def to_cups
    self * CUP_PER_L
  end
  alias to_cup to_cups

  def lbs
    to_f / LBS_PER_KG
  end

  def mi
    to_f / MI_PER_KM
  end
  alias mph mi

  def yd
    to_f / (MI_PER_KM * YD_PER_MI)
  end

  def ft
    to_f / (MI_PER_KM * YD_PER_MI * FT_PER_YD)
  end

  def km
    self
  end

  def m
    to_f / 1000
  end

  def kg
    self
  end

  def kcal
    self
  end

  def kJ
    to_f / KJ_PER_KCAL
  end

  def cups
    to_f / CUP_PER_L
  end
  alias cup cups

  def L
    self
  end

  def F
    (self - 32) * (5.0 / 9)
  end
end
