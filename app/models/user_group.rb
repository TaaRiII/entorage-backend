class UserGroup < ApplicationRecord
    belongs_to :user
    belongs_to :group

    enum status: %w[pending joined reported]
    attr_accessor :invite_id

    before_save   :check_invitation_or_direct_add, if: ->(obj){ obj.invite_id.present? }
    before_save   :send_invite_accepted_notification, if: ->(obj){ obj.status_was == 'pending' and obj.joined? }
    after_save    :handle_group_status, :decide_creator_to_set_coordinates, if: :joined?
    # after_save    :enable_new_user_spotlight, if: :joined?
    after_destroy :send_leave_notification, :change_creator_and_coordinates, if: :joined?
    after_destroy :send_invite_decline_notification, :delete_group_if_empty, if: :pending?

    #Scope
    scope :active, -> { where(status: 'joined') }

    # def enable_new_user_spotlight
    #   if user.is_new && !group.spot_light_enabled
    #     group.spot_light_enabled  = true
    #     group.spot_light_time = DateTime.now
    #     group.save
    #     group.set_spot_light_off_job
    #     user.decrement!(:spot_light_allow, 1)
    #     user.is_new = false
    #     user.save
    #   end
    # end

    def check_invitation_or_direct_add
      joined_group = self.user.user_groups.active
      if joined_group.present? && joined_group.first.group.active?
        send_new_invitation_notification
        send_new_invited_notification_to_group_members
      else
        send_direct_add_notification
        send_new_direct_add_notification_to_group_members
        self.status = 'joined'
        remove_previous_group
      end
    end

    def send_direct_add_notification
      inviter = User.find_by_id invite_id
      fcm_tokens = Device.joins(user: [:setting]).where(users: {id: self.user.id}, settings: {group: true}).pluck(:fcm_token).uniq
      fcm_tokens_silent = self.user.devices.pluck(:fcm_token).uniq
      message = "#{inviter.full_name} added you to their Group! 😃"

      extra_data = ActiveModel::ArraySerializer.new(User.where(id: self.user.id), each_serializer: UserNotificationSerializer, root: "users").as_json
      FirebaseNotification.firebase_notifications(fcm_tokens, "GroupAdd", self.group_id, message, nil, extra_data) if fcm_tokens.present?
      FirebaseNotification.firebase_silent_notifications(fcm_tokens_silent, "GroupAdd", self.group_id, message, nil, extra_data) if fcm_tokens_silent.present?
    end

    def send_new_direct_add_notification_to_group_members
      fcm_tokens = self.group.users.joined_group.joins(:devices, :setting).where.not(devices: {user_id: invite_id}).where(settings: {group: true}).pluck(:fcm_token)
      fcm_tokens_silent = self.group.users.joined_group.joins(:devices).where.not(devices: {user_id: invite_id}).pluck(:fcm_token)
      message = "#{self.user.full_name} was added to your Group! 😃."
      FirebaseNotification.firebase_notifications(fcm_tokens, "GroupInviteAccepted", self.group_id, message) if fcm_tokens.present?
      FirebaseNotification.firebase_silent_notifications(fcm_tokens_silent, "GroupInviteAccepted", self.group_id, message) if fcm_tokens_silent.present?
    end

    def send_new_invitation_notification
      fcm_tokens = Device.joins(user: [:setting]).where(users: {id: self.user.id}, settings: {group: true}).pluck(:fcm_token).uniq
      fcm_tokens_silent = self.user.devices.pluck(:fcm_token).uniq
      # members = self.group.users.count
      inviter = User.find_by_id invite_id

      # if members > 2
      #   message = "#{inviter.full_name} invited you to join a group with #{members - 2} other(s)."
      # else
      #   message = "#{inviter.full_name} invited you to join a group."
      # end
      message = "#{inviter.full_name} invited you to their Group! 😆"
      FirebaseNotification.firebase_notifications(fcm_tokens, "GroupInvite", self.group_id, message) if fcm_tokens.present?
      FirebaseNotification.firebase_silent_notifications(fcm_tokens_silent, "GroupInvite", self.group_id, message) if fcm_tokens_silent.present?
    end

    def send_new_invited_notification_to_group_members
      inviter = User.find_by_id invite_id
      fcm_tokens = self.group.users.joined_group.joins(:devices, :setting).where.not(devices: {user_id: invite_id}).where(settings: {group: true}).pluck(:fcm_token)
      fcm_tokens_silent = self.group.users.joined_group.joins(:devices).where.not(devices: {user_id: invite_id}).pluck(:fcm_token)
      message = "#{self.user.full_name} was invited to your Group! 😃"
      FirebaseNotification.firebase_notifications(fcm_tokens, "GroupInviteNew", self.group_id, message) if fcm_tokens.present?
      FirebaseNotification.firebase_silent_notifications(fcm_tokens_silent, "GroupInviteNew", self.group_id, message) if fcm_tokens_silent.present?
    end

    def send_leave_notification
      fcm_tokens = self.group.users.joined_group.joins(:devices, :setting).where.not(devices: {user_id: self.user_id}).where(settings: {group: true}).pluck(:fcm_token)
      fcm_tokens_silent = self.group.users.joined_group.joins(:devices).where.not(devices: {user_id: self.user_id}).pluck(:fcm_token)
      members = self.group.users.joined_group.count
      if members >= 2
        message = "#{self.user.full_name} left the group 🙃"
      else
        message = "Group Expired, Create a New Group? ⏱"
      end
      self.handle_group_status
      self.group.set_name
      self.group.set_age_gender_and_count
      FirebaseNotification.firebase_notifications(fcm_tokens, "GroupLeft", self.group_id, message) if fcm_tokens.present?
      FirebaseNotification.firebase_silent_notifications(fcm_tokens_silent, "GroupLeft", self.group_id, message) if fcm_tokens_silent.present?
    end

    def change_creator_and_coordinates
      if user == group.creator
        second_group_user = self.group.users.joined_group.first
        if second_group_user.present?
          self.group.decide_creator_to_set_coordinates
        else
          self.group.destroy
        end
      end
    end

    def send_invite_accepted_notification
      fcm_tokens = self.group.users.joined_group.joins(:devices, :setting).where.not(devices: {user_id: self.user_id}).where(settings: {group: true}).pluck(:fcm_token)
      fcm_tokens_silent = self.group.users.joined_group.joins(:devices).where.not(devices: {user_id: self.user_id}).pluck(:fcm_token)
      message = "#{self.user.full_name} accepted the invite to your Group! 🤩"
      FirebaseNotification.firebase_notifications(fcm_tokens, "GroupInviteAccepted", self.group_id, message) if fcm_tokens.present?
      FirebaseNotification.firebase_silent_notifications(fcm_tokens_silent, "GroupInviteAccepted", self.group_id, message) if fcm_tokens_silent.present?
      remove_previous_group
    end

    def send_invite_decline_notification
      fcm_tokens = self.group.users.joined_group.joins(:devices, :setting).where.not(devices: {user_id: self.user_id}).where(settings: {group: true}).pluck(:fcm_token)
      fcm_token_silent = self.group.users.joined_group.joins(:devices).where.not(devices: {user_id: self.user_id}).pluck(:fcm_token)
      message = "#{self.user.full_name} declined the invite to your Group! 🙃"
      FirebaseNotification.firebase_notifications(fcm_tokens, "GroupInviteDeclined", self.group_id, message) if fcm_tokens.present?
      FirebaseNotification.firebase_silent_notifications(fcm_token_silent, "GroupInviteDeclined", self.group_id, message) if fcm_token_silent.present?
    end

    def remove_previous_group
      #send silent notification to all matches as well
      self.user.user_groups.where.not(id: self.id).where(status: 'joined').destroy_all
    end

    def delete_group_if_empty
      self.group.delete if self.group.users.count.zero?
    end

    def handle_group_status
      self.group.handle_group_status
      self.group.set_name
      self.group.set_age_gender_and_count
    end

    def decide_creator_to_set_coordinates
      self.group.decide_creator_to_set_coordinates if self.group.latitude.blank?
    end
  end