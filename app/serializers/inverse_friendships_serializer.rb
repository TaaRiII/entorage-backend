class InverseFriendshipSerializer < ActiveModel::Serializer
  attributes :id,:user_id, :status, :friend

  def friend
     CustomUserSerializer.new(object.user, root:false)
  end

  def user_id
    object.friend_id
  end
end
