class Match < ApplicationRecord
  belongs_to :group
  belongs_to :matcher, :class_name => "Group"

  belongs_to :user

  #

  attr_accessor :instant
  enum status: %w[like match unlike block blocked report reported]
  after_destroy :send_unmatch_notification, if: :match?

  def check_match
    existing_like = Match.where(group_id: self.matcher_id, matcher_id: self.group_id, status: 'like').first
    if existing_like.present?
      existing_like.update_column(:status, 'match')
      self.update_column(:status, 'match')
      Match.where(group_id: self.matcher_id, matcher_id: self.group_id, status: 'like').where.not(id: existing_like.id).destroy_all
      Match.where(group_id: self.group_id, matcher_id: self.matcher_id).where.not(id:  self.id).destroy_all
      Match.where(id: [existing_like.id, self.id]).update_all(chat_id: existing_like.id)
      send_match_notification(existing_like.id)
      self.reload
    end
    self
  end

  def send_match_notification(existing_like_id)
    notification_type = self.instant ? "MatchInstant" : "MatchCreated"
    group_fcm_tokens = self.group.users.joined_group.joins(:devices, :setting).where.not("users.id=?", self.user_id).where(settings: {match: true}).pluck(:fcm_token)
    extra_data = ActiveModel::ArraySerializer.new(self.matcher.users.joined_group, each_serializer: UserNotificationSerializer, root: "users").as_json

    FirebaseNotification.firebase_notifications(group_fcm_tokens, notification_type, self.id, "You got a new Group match! 😎😎😎", nil, extra_data) if group_fcm_tokens.present?
    matcher_fcm_tokens = self.matcher.users.joined_group.joins(:devices, :setting).where(settings: {match: true}).pluck(:fcm_token)
    extra_data = ActiveModel::ArraySerializer.new(self.group.users.joined_group, each_serializer: UserNotificationSerializer, root: "users").as_json
    FirebaseNotification.firebase_notifications(matcher_fcm_tokens, "MatchCreated", existing_like_id, "You got a new Group match! 😎😎😎", nil, extra_data) if matcher_fcm_tokens.present?
  end

  # def check_block
  #   group_users_count = self.group.users.count
  #   existing_unlike_count = Match.where(group_id: self.group_id, matcher_id: self.matcher_id, status: 'unlike').count
  #   if group_users_count == existing_unlike_count
  #     self.update_attributes(status: 'block')
  #     existing = Match.where(group_id: self.matcher_id, matcher_id: self.group_id).first_or_initialize
  #     existing.user_id = self.matcher.creator_id
  #     existing.status = 'blocked'
  #     existing.save

  #     Match.where(group_id: self.matcher_id, matcher_id: self.group_id).where.not(id: existing.id).destroy_all
  #     Match.where(group_id: self.group_id, matcher_id: self.matcher_id).where.not(id:  self.id).destroy_all
  #   end
  #   self
  # end

  def send_unmatch_notification
    fcm_tokens = self.group.users.joined_group.joins(:devices).pluck(:fcm_token)
    FirebaseNotification.firebase_silent_notifications(fcm_tokens, "UnMatch", self.id, "Unmacthed" ) if fcm_tokens.present?
  end

end
