class FriendshipUserSerializer < ActiveModel::Serializer
  attributes :status, :friend

  def friend
    CustomUserSerializer.new(object.friend, root:false)
  end
end
