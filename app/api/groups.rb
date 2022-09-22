class Groups < Grape::API
  include Authentication
  resource :groups do

    desc 'Create Group with friends'
    params do
      requires :auth_token, type: String, desc: 'Auth Token'
      requires :group_status_id, type:  Integer, desc: 'Group Status ID'
      requires :friend_ids, type: String, desc: "friend_ids like [1,2,3]"
    end
    post 'create' do
      group = current_user.group_creations.create(group_status_id: permitted_params[:group_status_id])
      current_user.update_column(:creator, true)
      friend_ids = JSON.parse(permitted_params[:friend_ids])
      error!('You can only add 3 friends', 401) if friend_ids.length > 3
      friend_ids << current_user.id
      #make group members
      friend_ids.each do |friend_id|
        user_group = group.user_groups.where(user_id: friend_id).first_or_initialize
        if friend_id == current_user.id
          user_group.update_attributes(status: 'joined')
        else
          user_group.update_attributes(invite_id: current_user.id)
        end
      end

      group.set_name
      group.handle_group_status
      group.set_age_gender_and_count
      group.decide_creator_to_set_coordinates if group.latitude.blank?
      MyGroupSerializer.new(group, context: { user_id: current_user.id }, root: 'group').as_json
    end

    desc 'My Group'
    params do
      requires :auth_token, type: String, desc: 'Auth Token'
    end
    get 'my_group' do
      group = current_user.groups.joined_group.first
      error!('Create or join a group first', 401) if group.nil?
      MyGroupSerializer.new(group, context: { user_id: current_user.id }, root: 'group').as_json
    end

    desc 'Enable Spot Light'
    params do
      requires :auth_token, type: String, desc: 'Auth Token'
    end
    post 'enable_spot_light' do
      group = current_user.groups.joined_group.first
      error!('Create or join a group first', 401) if group.nil?
      error!('No Spot Light Available', 401) if group.spot_light_allow.zero? || current_user.spot_light_allow.zero?
      group.spot_light_allow = group.spot_light_allow - 1
      group.spot_light_enabled  = true
      group.spot_light_time = DateTime.now
      group.save
      group.set_spot_light_off_job
      current_user.decrement!(:spot_light_allow, 1)
      group
    end

    desc 'Group By ID'
    params do
      requires :auth_token, type: String, desc: 'Auth Token'
      requires :group_id, type:  Integer, desc: 'Group ID'
    end
    get 'group_by_id' do
      group = Group.find_by_id permitted_params[:group_id]
      error!('Invalid Group Id', 401) if group.nil?
      group
    end

    desc 'Add Member'
    params do
      requires :auth_token, type: String, desc: 'Auth Token'
      requires :group_id, type:  Integer, desc: 'Group ID'
      requires :friend_id, type:  Integer, desc: 'Friend ID'
    end
    post 'add_member' do
      group = Group.find_by_id(permitted_params[:group_id])
      valid_friends = group.users.count
      error!('You can only add 3 friends', 401) if valid_friends >= 4
      if group.present?
        user_group = group.user_groups.where(user_id: permitted_params[:friend_id]).first_or_initialize
        user_group.invite_id = current_user.id
        user_group.save

        MyGroupSerializer.new(group, context: { user_id: current_user.id }, root: 'group').as_json
      else
        error!('Group doesnot exist', 401)
      end
    end

    desc 'Delete Group Invitation'
    params do
      requires :auth_token, type: String, desc: 'Auth Token'
      requires :group_id, type:  Integer, desc: 'Group ID'
      requires :friend_id, type:  Integer, desc: 'Friend ID'
    end
    delete 'delete_invitation' do
      group = Group.find_by_id(permitted_params[:group_id])
      if group.present?
        user_group = group.user_groups.where(user_id: permitted_params[:friend_id]).first
        if user_group.present?
          user_group.delete
        end
        MyGroupSerializer.new(group, context: { user_id: current_user.id }, root: 'group').as_json
      else
        error!('Group doesnot exist', 401)
      end
    end


    desc 'Accept Group Invitation'
    params do
      requires :auth_token, type: String, desc: 'Auth Token'
      requires :group_id, type:  Integer, desc: 'Group ID'
    end
    post 'accept_group_invitation' do
      user_group = current_user.user_groups.where(group_id: permitted_params[:group_id]).first
      error!('Sorry, no such invitation exists', 401) if user_group.nil?
      user_group.update_attributes(status: 'joined')
      MyGroupSerializer.new(user_group.group, context: { user_id: current_user.id }, root: 'group').as_json
    end

    desc 'Reject Group Invitation'
    params do
      requires :auth_token, type: String, desc: 'Auth Token'
      requires :group_id, type:  Integer, desc: 'Group ID'
    end

    delete 'reject_group_invitation' do
      user_group = current_user.user_groups.where(group_id: permitted_params[:group_id]).first
      error!('Sorry, no such invitation exists', 401) if user_group.nil?
      user_group.destroy
      render :message => "Invitation Declined".as_json
    end

    desc 'Leave Group'
    params do
      requires :auth_token, type: String, desc: 'Auth Token'
    end
    delete 'leave_group' do
      user_group = current_user.user_groups.active.first
      error!('Create or join a group first', 401) if user_group.nil?
      user_group.destroy
      current_user
    end

    desc 'Update Group Status'
    params do
      requires :auth_token, type: String, desc: 'Auth Token'
      requires :group_id, type:  Integer, desc: 'Group ID'
      optional :group_status_id, type:  Integer, desc: 'Group Status ID'
    end
    put 'update_group_status' do
      group = current_user.groups.joined_group.first
      custom_group_status = current_user.group_statuses.where(id: permitted_params[:group_status_id]).first
      if group.present?
        group.group_status_id = permitted_params[:group_status_id] if permitted_params[:group_status_id].present?
        group.operator_id = current_user.id
        group.save
        custom_group_status.touch if custom_group_status.present?
        MyGroupSerializer.new(group, context: { user_id: current_user.id }, root: 'group').as_json
      else
        error!('Group doesnot exist', 401)
      end
    end

  end
end
