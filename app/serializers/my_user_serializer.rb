class MyUserSerializer < ActiveModel::Serializer
  attributes :id, :phone_number, :authentication_token, :user_name, :bio, :first_name, :is_blocked,
             :last_name, :latitude, :longitude, :dob, :age, :gender, :city, :state,
             :instant_match_allow, :spot_light_allow, :pending_group_invitation
  has_many :photos

  def dob
   object.dob.to_time.to_i if object.dob.present?
  end

  def pending_group_invitation
    ActiveModel::ArraySerializer.new(object.groups.pending_group, each_serializer: GroupSerializer)
  end

end
