class AgeUpdateWorker
  include Sidekiq::Worker

  def perform(*args)
    User.today_birthday.each do |user|
      now = Time.now.utc.to_date
      user.age = now.year - user.dob.year - ((now.month > user.dob.month || (now.month == user.dob.month && now.day >= user.dob.day)) ? 0 : 1)
      user.save
    end
  end
end
