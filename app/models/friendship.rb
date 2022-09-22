class Friendship < ApplicationRecord
  belongs_to :user
  belongs_to :friend, :class_name => "User"  #, :foreign_key => "friend_id"

  enum status: %w[requested match block accept blocked unfriend]

  after_save :send_notifications, if: ->(obj){ obj.status_changed? }
  # before_save :conditional_leave_group, if: :block?

  def send_notifications
    fcm_tokens = []
    title = nil
    if self.requested?
      fcm_tokens_silent = self.friend.devices.pluck(:fcm_token).uniq
      fcm_tokens = Device.joins(user: [:setting]).where(users: {id: self.friend.id}, settings: {friendship: true}).pluck(:fcm_token).uniq
      message = "#{self.user.full_name} sent you a Friend Request 🤩"
      type = "FriendshipRequest"
      user_id = self.user_id
    elsif self.match?
      fcm_tokens_silent = self.friend.devices.pluck(:fcm_token).uniq
      fcm_tokens = Device.joins(user: [:setting]).where(users: {id: friend.id}, settings: {friendship: true}).pluck(:fcm_token).uniq
      title = "#{self.user.full_name} accepted your friend request."
      # message = "You can now add #{self.user.first_name.titleize} to a Group."
      message = "self.user.full_name} Accepted your Friend Request 🤩"
      type = "FriendshipAccepted"
      user_id = self.friend_id
    end
    FirebaseNotification.firebase_notifications(fcm_tokens, type, user_id, message, title) if fcm_tokens.present?
    FirebaseNotification.firebase_silent_notifications(fcm_tokens_silent, type, user_id, message) if fcm_tokens_silent.present?
  end

  # def conditional_leave_group
  #   group = self.user.groups.joined_group.first
  #   if group.present?
  #    user_group =  UserGroup.where(group_id: group.id, user_id: friend_id, status: 'joined').first
  #    if user_group.present?
  #       self.user.user_groups.active.first.destroy
  #    end
  #   end
  # end

  # def handle_block
  #   block2 = self.friend.friendships.where(friend_id: user_id).first_or_initialize
  #   block2.status = 'blocked'
  #   block2.save
  # end
  #
  # def handle_unblock
  #   self.friend.friendships.where(friend_id: user_id).destroy
  # end
end
