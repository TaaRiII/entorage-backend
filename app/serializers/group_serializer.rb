class GroupSerializer < ActiveModel::Serializer
  attributes :id, :status, :name, :city, :state, :users
  has_one :group_status


  def users
    users =  object.users.joined_group
    if context.present? && context[:user_id].present?
      users = users.partition { |v| v.id != context[:user_id] }.reduce(:+)
    end
    ActiveModel::ArraySerializer.new(users, each_serializer: UserSerializer)
  end

end
