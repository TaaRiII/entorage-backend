class Group < ApplicationRecord
  has_many :user_groups, dependent: :destroy
  has_many :users, through: :user_groups

  belongs_to :creator, :class_name => "User", :foreign_key => "creator_id"

  belongs_to :group_status

  has_many :matches, dependent: :destroy
  has_many :liked, :through => :matches, :source => :macther

  has_many :inverse_matches , :class_name => "Match" , :foreign_key => "matcher_id", dependent: :destroy
  has_many :liked_by, :through => :inverse_matches, :source => :group

  enum status: %w[active inactive]
  enum gender: %w[male female other mix]

  reverse_geocoded_by :latitude, :longitude
  # after_validation :reverse_geocode

  before_save  :set_coordinates, if: :will_save_change_to_creator_id?
  after_update :send_status_change_notificaiton
  after_save   :send_spot_light_notification, if: ->(obj){ obj.spot_light_enabled_changed? && obj.spot_light_enabled}
  after_save   :send_spot_light_end_notification, if: ->(obj){ obj.spot_light_enabled_changed? && !obj.spot_light_enabled}

  #attribute accessor
  attr_accessor :operator_id

  #Scope
  scope :joined_group, -> { where("user_groups.status=?", 1) }
  scope :pending_group, -> { where("user_groups.status=?", 0) }

  # scope :filter_by_gender, -> (gender)  { where( gender: gender) }
  # scope :filter_by_users_count, -> (count) { where( users_count: count) }


  def set_coordinates
    self.latitude = creator.latitude
    self.longitude = creator.longitude
    # self.city = creator.city
    # self.state = creator.state
  end

  def handle_group_status
    if self.users.joined_group.count < 2
      self.update_attributes(status: 'inactive')
    else
      self.update_attributes(status: 'active')
    end
  end

  def set_name
    name = self.users.joined_group.pluck(:first_name).compact.join(', ').to_s
    name = name.reverse.sub(',', 'dna ').reverse
    self.update_column(:name, name)
  end

  def set_age_gender_and_count
    user_groups = self.user_groups.where(status: "joined")
    min_age = user_groups.joins(:user).minimum("users.age")
    max_age = user_groups.joins(:user).maximum("users.age")
    genders = user_groups.joins(:user).pluck("users.gender").uniq
    gender = 3
    if genders.length == 1
      gender = genders[0]
    end
    self.update_columns(users_count: user_groups.length, min_age: min_age, max_age: max_age, gender: gender)
  end

  def send_status_change_notificaiton
    if self.saved_changes.present? && self.saved_changes[:group_status_id].present?
      fcm_tokens = self.users.joined_group.joins(:devices, :setting).where.not(devices: {user_id: self.operator_id}).where(settings: {group: true}).pluck(:fcm_token)
      fcm_tokens_silent = self.users.joined_group.joins(:devices).where.not(devices: {user_id: self.operator_id}).pluck(:fcm_token).uniq
      operator = User.find_by_id(self.operator_id)
      message = "#{operator.full_name} changed your Group Status 🔁"
      FirebaseNotification.firebase_notifications(fcm_tokens, "GroupStatusChanged", self.id, message) if fcm_tokens.present?
      FirebaseNotification.firebase_silent_notifications(fcm_tokens, "GroupStatusChanged", self.id, "#{operator.full_name} updated the group status") if fcm_tokens_silent.present?
    end
  end

  def send_spot_light_notification
    fcm_tokens_silent = self.users.joined_group.joins(:devices).pluck(:fcm_token).uniq
    FirebaseNotification.firebase_silent_notifications(fcm_tokens, "GroupSpotlightEnabled", self.id, "Spotlight Enabled") if fcm_tokens_silent.present?
  end

  def send_spot_light_end_notification
    fcm_tokens = self.users.joined_group.joins(:devices, :setting).where(settings: {group: true}).pluck(:fcm_token)
    fcm_tokens_silent = self.users.joined_group.joins(:devices).pluck(:fcm_token).uniq
    message = "🕺 Your Spotlight has Ended, See your Matches"
    FirebaseNotification.firebase_notifications(fcm_tokens, "GroupSpotlightDisabled", self.id, message) if fcm_tokens.present?
    FirebaseNotification.firebase_silent_notifications(fcm_tokens, "GroupSpotlightDisabled", self.id, "Spotlight Disabled") if fcm_tokens_silent.present?
  end



  def send_profile_picture_changed_notification operator_id
    fcm_tokens = self.users.joined_group.joins(:devices).where.not(devices: {user_id: self.operator_id}).pluck(:fcm_token).uniq
    FirebaseNotification.firebase_silent_notifications(fcm_tokens, "ProfilePicUpdated", self.id, "Profile Picture Updated") if fcm_tokens.present?
  end

  def set_spot_light_off_job
    SpotLightEndWorker.perform_at(self.spot_light_time + 30.minutes, self.id)
  end

  def decide_creator_to_set_coordinates
    self.users.joined_group.each do |user|
      if user.latitude.present?
        self.update_attributes(creator_id: user.id)
        break
      end
    end
  end

  def self.test(data)
    group_statuses_ids = GroupStatus.pluck(:id)
    50.times do
      data.each do |row|
        user_ids = []
        row  = row.with_indifferent_access
        row[:users].each do |user_row|
          user_row[:phone_number] = Faker::Base.unique.numerify('+1###########')
          last_name = Faker::Name.last_name.gsub(/[^0-9a-z ]/i, '')
          user = User.create!(phone_number: user_row[:phone_number], latitude: user_row[:latitude], longitude: user_row[:longitude],
                            user_name: last_name + rand(1000..10000).to_s , first_name: Faker::Name.first_name, last_name: last_name,
                            dob: user_row[:dob], gender: user_row[:gender])
          user.photos.create(image: URI.parse(user_row[:image_url]), is_primary: true, order: 0)
          user_ids << user.id
        end
        current_user = User.find(user_ids[0])
        friend = User.find(user_ids[1])

        friendship = current_user.friendships.where(friend_id: friend.id).first_or_initialize
        friendship.status = 'match'
        friendship.save

        inverse_friendship = friend.friendships.where(friend_id: current_user.id).first_or_initialize
        inverse_friendship.status = 'match'
        inverse_friendship.save


        group = current_user.group_creations.create(group_status_id: group_statuses_ids.sample)
        current_user.update_column(:creator, true)
        user_ids.each do |friend_id|
          user_group = group.user_groups.where(user_id: friend_id).first_or_create
          user_group.update_column(:status, 'joined')
        end
        group.handle_group_status
        group.set_coordinates
        group.set_name
      end
    end
  end

end
