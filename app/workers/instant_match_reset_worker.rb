class InstantMatchResetWorker
  include Sidekiq::Worker

  def perform(*args)
    Group.update_all(instant_match_allow: 1)
    User.update_all(instant_match_allow: 1)
  end
end
