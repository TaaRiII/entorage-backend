class KickOutUserWorker
  include Sidekiq::Worker

  def perform(*args)
    User.where("created_at <=?", 1.day.ago).where("gender is NULL OR first_name IS NULL OR dob IS NULL").destroy_all
  end
end
