class SpotLightResetWorker
  include Sidekiq::Worker

  def perform(*args)
    Group.update_all(spot_light_allow: 1)
    User.update_all(spot_light_allow: 1)
  end
end
