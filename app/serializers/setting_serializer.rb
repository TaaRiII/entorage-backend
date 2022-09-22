class SettingSerializer < ActiveModel::Serializer
  attributes :everyone, :male_only, :female_only, :min_age, :max_age, :group_member_count,
             :block_member_count, :max_distace, :general, :friendship, :match, :group, :chat

  def block_member_count
    object.user.friendships.where("friendships.status=?",2).count
  end
end
