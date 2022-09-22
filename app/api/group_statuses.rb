class GroupStatuses < Grape::API
  include Authentication
  resource :group_statuses do

    desc 'get group statuses'
    params do
      requires :auth_token, type: String, desc: 'Auth Token'
      optional :status_type, type: String, values: ["default", "place"]
    end
    get 'all' do
      status_type = params[:status_type].present? ? params[:status_type] : "default"
      if status_type == "place"
        group_statuses = GroupStatus.where(status_type: status_type).kept.near([current_user.latitude, current_user.longitude], 100000)
      else
        group_statuses = GroupStatus.where(status_type: status_type).kept
      end
      group = current_user.groups.joined_group.first
      if group.present? && group.group_status.present? &&  group.group_status.discarded?
        if status_type == "place"
          group_statuses = group_statuses + GroupStatus.where(id: group.group_status_id)
        else
          group_statuses = group_statuses.or(GroupStatus.where(id: group.group_status_id))
        end
      end
      group_statuses= group_statuses.order(:position) unless status_type == "place"
      group_statuses

    end

    desc 'recent 5 group statuses'
    params do
      requires :auth_token, type: String, desc: 'Auth Token'
    end
    get 'recent' do
      group_statuses = []
      group = current_user.groups.joined_group.first
      if group.present? && group.group_status.present? &&  group.group_status.discarded?
        group_statuses << GroupStatus.find_by(id: group.group_status_id)
      end
      group_statuses += current_user.group_statuses.kept.where(status_type: 'custom').order(updated_at: :desc).first(5)
      group_statuses
    end

    #create status
    desc 'create'
    params do
      requires :auth_token, type: String, desc: 'Auth Token'
      requires :name, type: String, desc: 'Name'
      requires :icon, type: File, desc: 'Image'
    end
    post 'create' do
      group_status = current_user.group_statuses.where(name: params[:name], status_type: 'custom').first_or_initialize
      group_status.icon = params[:icon]
      if group_status.save
        group = current_user.groups.joined_group.first
        if group.present?
          group.group_status_id = group_status.id
          group.operator_id = current_user.id
          group.save
        end
      end
      group_status
    end

  end
end
