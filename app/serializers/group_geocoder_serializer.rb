class GroupGeocoderSerializer < ActiveModel::Serializer
  attributes :id, :status, :name, :city, :state, :distance, :users
  has_one :group_status


  def distance
    distance = object.distance.round(0)
    if distance  < 1
      "1 mile"
    else
      distance.to_s + " Mi."
    end
  end

  def users
    ActiveModel::ArraySerializer.new(object.users.joined_group.includes(:setting, :devices, :photos), each_serializer: UserSerializer)
  end

end
