class FriendshipUserSerializer < ActiveModel::Serializer
  attributes :id, :status, :phone_number, :user_name, :first_name, :last_name, :is_blocked, :photos

  def friend
    @friend ||= object.friend
  end

  def id
    friend.id
  end

  def phone_number
    friend.phone_number
  end
  def user_name
    friend.user_name
  end
  def first_name
    friend.first_name
  end

  def last_name
    friend.last_name
  end

  def is_blocked
    friend.is_blocked
  end

  def photos
    ActiveModel::ArraySerializer.new(friend.photos.where(is_primary: true), each_serializer: PhotoSerializer)
  end

end
