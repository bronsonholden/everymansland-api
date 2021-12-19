module FitConstants
  extend ActiveSupport::Concern

  included do
    enum gender: %i[female male]
    enum sport: %i[
      generic
      running
      cycling
      transition
      fitness_equipment
      swimming
      basketball
      soccer
      tennis
      american_football
      training
      walking
      cross_country_skiing
      alpine_skiing
      snowboarding
      rowing
      mountaineering
      hiking
      multisport
      paddling
      flying
      e_biking
      motorcycling
      boating
      driving
      golf
      hang_gliding
      horseback_riding
      hunting
      fishing
      inline_skating
      rock_climbing
      sailing
      ice_skating
      sky_diving
      snowshoeing
      snowmobiling
      stand_up_paddleboarding
      surfing
      wakeboarding
      water_skiing
      kayaking
      rafting
      windsurfing
      kitesurfing
      tactical
      jumpmaster
      boxing
      floor_climbing
      diving
    ]
  end
end
