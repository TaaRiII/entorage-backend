class CustomUserSerializer < ActiveModel::Serializer
  attributes :id, :phone_number, :user_name, :first_name, :last_name, :is_blocked, :photos

  def photos
    ActiveModel::ArraySerializer.new(object.photos.where(is_primary: true), each_serializer: PhotoSerializer)
  end

end
