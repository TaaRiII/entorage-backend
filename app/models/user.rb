class User < ApplicationRecord
  # geocoded_by :ip_address

  # reverse_geocoded_by :latitude, :longitude do |obj,results|
  #   if geo = results.first
  #     obj.city    = geo.city
  #     obj.state = geo.state
  #   end
  # end

  # after_validation :reverse_geocode, if: ->(obj){ obj.latitude_changed? and obj.longitude_changed? }
  phony_normalize :phone_number, default_country_code: 'US'
  before_save :change_group_coordinates, if: ->(obj){ obj.latitude_changed? or obj.longitude_changed? }
  # before_save :phone_number_format


  has_many :photos, dependent: :destroy
  has_many :devices,dependent: :destroy
  has_many :notifications,dependent: :destroy
  has_one :setting, dependent: :destroy

  has_many :friendships, dependent: :destroy #, :class_name => "Friendship", :foreign_key => 'user_id'
  has_many :invited, :through => :friendships, :source => :friend

  has_many :inverse_friendships , :class_name => "Friendship" , :foreign_key => "friend_id", dependent: :destroy
  has_many :invited_by, :through => :inverse_friendships, :source => :user

  has_many :user_groups, dependent: :destroy
  has_many :groups, through: :user_groups

  has_many :group_creations, :foreign_key => :creator_id, :class_name => 'Group'
  has_many :group_statuses

  has_many :reported, :class_name => 'Report'
  has_many :reports, :foreign_key => :reporter_id, :class_name => 'Report'

  has_many :matches, dependent: :destroy
  accepts_nested_attributes_for :photos, reject_if: :all_blank, allow_destroy: true

  enum gender: %w[male female other]

  # after_validation :geocode
  validates :phone_number, :user_name, uniqueness: true
  validates_format_of :user_name, :with => /^[A-Za-z0-9]+$/, :multiline => true

  validate do
    sex_filter = LanguageFilter::Filter.new matchlist: :sex
    if sex_filter.match?(user_name.to_s) || sex_filter.match?(first_name.to_s) 
      self.errors.add(:base, "connot use these prohibited words in name")
    end
  end

  before_create :ensure_authentication_token
  before_save :set_age, if: ->(obj){ obj.dob.present? && obj.dob_changed? }
  after_create :initialize_settings
  before_save :send_banned_push, if: ->(obj){ obj.is_blocked_changed? or obj.is_blocked }
  before_destroy :remove_groups


  #Scope
  scope :joined_group, -> { where("user_groups.status=?", 1) }
  scope :pending_group, -> { where("user_groups.status=?", 0) }
  scope :only_unbanned, -> { where(is_blocked: false) }
  scope :today_birthday, ->{ where('EXTRACT(month FROM dob) = ? AND EXTRACT(day FROM dob) = ?', Date.today.month, Date.today.day) }
  scope :active, -> {where("last_used >=?",12.hours.ago)}

   def ensure_authentication_token
       self.authentication_token = generate_authentication_token
   end

   def generate_authentication_token
     loop do
       token = Devise.friendly_token
       break token unless User.where(authentication_token: token).first
     end
   end


   def set_age
     now = Time.now.utc.to_date
     self.age = now.year - dob.year - ((now.month > dob.month || (now.month == dob.month && now.day >= dob.day)) ? 0 : 1)
   end

   def initialize_settings
     self.create_setting
   end

   def full_name
    [first_name, last_name].compact.split("").flatten.join(' ').titleize
   end

   def change_group_coordinates
    group = self.group_creations.first
    if group.present?
      group.set_coordinates
      group.save
    end
   end

   def set_gender_priority(gender)
    setting = self.setting
    if gender == "male"
      setting.update_attributes(female_only: true)
    elsif gender == "female"
      setting.update_attributes(male_only: true)
    else
      setting.update_attributes(everyone: true)
    end
   end

   def send_banned_push
    fcm_tokens = devices.pluck(:fcm_token)
    FirebaseNotification.firebase_silent_notifications(fcm_tokens, "Banned", self.id, "Banned" ) if fcm_tokens.present?
    remove_groups
   end

   def remove_groups
    self.user_groups.destroy_all
   end

end
