class UserSerializer < ActiveModel::Serializer
  attributes :id,:name,:email,:authentication_token,:avatar
  has_one :setting
  
  def avatar
    object.avatar.present? ? HOST+ActionController::Base.helpers.image_path(object.avatar.url(:medium)) : nil
  end


end
