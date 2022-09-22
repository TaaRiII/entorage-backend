class SpotLightEndWorker
  include Sidekiq::Worker

  def perform(group_id)
    group = Group.find_by_id group_id
    if group.present?
      group.update_attributes(spot_light_enabled: false, spot_light_time: nil)
    end
  end
end
