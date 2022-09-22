class MyGroupSerializer < ActiveModel::Serializer
  attributes :id, :status, :name, :city, :state, :instant_match_allow, :spot_light_allow,
             :spot_light_enabled, :spot_light_time, :users, :pending_approval
  has_one :group_status


  def users
    ActiveModel::ArraySerializer.new(object.users.joined_group, each_serializer: UserSerializer)
  end

  def pending_approval
    ActiveModel::ArraySerializer.new(object.users.pending_group, each_serializer: UserSerializer)
  end

  def spot_light_time
    if object.spot_light_time.present?
      ((object.spot_light_time + 30.minutes) - DateTime.now).to_i
    else
      0
    end
  end

end
