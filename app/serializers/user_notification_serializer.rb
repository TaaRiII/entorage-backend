class UserNotificationSerializer < ActiveModel::Serializer
  attributes :id, :user_name, :photo

  def user_name
    object.full_name
  end

  def photo
    photo = object.photos.where(is_primary: true).first
    photo.present? && photo.image.present? ? photo.image.url : nil
  end

end
