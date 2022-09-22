class Users < Grape::API
  resource :users do

    desc 'Return user profile'
    params do
      requires :auth_token, type: String, desc: 'Auth Token'
    end
    get 'user_by_auth_token' do
      user = User.find_by(authentication_token: params[:auth_token])
      if user.present?
        user.update_columns(last_used: Time.now)
        MyUserSerializer.new(user, root: 'user').as_json
      else
        error!('User doesnot exist with given Auth Token', 401)
      end
    end

    desc 'Return user profile'
    params do
      requires :phone_number, type: String, desc: 'Phone Number'
    end
    get 'user_by_phone_number' do
      user = User.find_by(phone_number: params[:phone_number])
      if user.present?
        MyUserSerializer.new(user, root: 'user').as_json
      else
        error!('User doesnot exist with given Phone Number', 401)
      end
    end

    desc 'Check User Name Available'
    params do
      requires :user_name, type: String, desc: 'User Name'
    end
    get 'user_name_available' do
      user = User.find_by(user_name: params[:user_name])
      if user.present? || !params[:user_name].match(/^[a-zA-Z0-9]+$/)
        error!('Not Available or Invalid Characters', 401)
      else
        render :message => "Available".as_json
      end
    end

    desc 'Search By User Name'
    params do
      requires :auth_token, type: String, desc: 'Auth Token'
      requires :user_name, type: String, desc: 'User Name'
    end
    get 'search_by_user_name' do
      current_user = User.find_by(authentication_token: params[:auth_token])
      error!('User doesnot exist with given Auth Token', 401) unless current_user.present?

      user_ids = User.where("user_name ILIKE?","#{params[:user_name]}%").where.not(id: current_user.id).pluck(:id)
      friendships =  current_user.friendships.where(friendships: {friend_id: user_ids,status: [0,1,3]})

      users_with_no_relation = user_ids - friendships.pluck(:friend_id)
      blocked_user_ids = current_user.friendships.where(friendships: {status: 2}).pluck(:friend_id) + current_user.inverse_friendships.where(friendships: {status: 2}).pluck(:user_id)
      users = User.where(id: users_with_no_relation).where.not(id: blocked_user_ids)

      response = {
                  friendships:  ActiveModel::ArraySerializer.new(friendships, each_serializer: FriendshipUserSerializer),
                  users: ActiveModel::ArraySerializer.new(users, each_serializer: CustomUserSerializer)
                  }
       response
    end

    desc 'Search By User Name (one response)'
    params do
      requires :auth_token, type: String, desc: 'Auth Token'
      requires :user_name, type: String, desc: 'User Name'
    end
    get 'search_by_user_name_custom' do
      current_user = User.find_by(authentication_token: params[:auth_token])
      error!('User doesnot exist with given Auth Token', 401) unless current_user.present?

      user_ids = User.where("user_name ILIKE?","#{params[:user_name]}%").where.not(id: current_user.id).pluck(:id)
      friendships =  current_user.friendships.where(friendships: {friend_id: user_ids,status: [0,1,3]})

      users_with_no_relation = user_ids - friendships.pluck(:friend_id)
      blocked_user_ids = current_user.friendships.where(friendships: {status: 2}).pluck(:friend_id) + current_user.inverse_friendships.where(friendships: {status: 2}).pluck(:user_id) + [current_user.id]
      users = User.where(id: users_with_no_relation).where.not(id: blocked_user_ids)
      friendships = ActiveModel::ArraySerializer.new(friendships, each_serializer: FriendshipUserSerializer).as_json
      users = ActiveModel::ArraySerializer.new(users, context: {status: 'no relation'}, each_serializer: UserFriendshipSerializer).as_json
      friendships + users
    end

    desc 'update coordinates of User by Auth Token'
    params do
      requires :auth_token, type: String, desc: 'Auth Token'
      requires :latitude, type: String, desc: 'Latitude'
      requires :longitude, type: String, desc: 'Longitude'
    end
    post 'update_coordinates' do
      user = User.find_by(authentication_token: params[:auth_token])
      if user.present?
        user.update_attributes(latitude: params[:latitude],longitude: params[:longitude] )
        MyUserSerializer.new(user, root: 'user').as_json
      else
        error!('User doesnot exist with given Auth Token', 401)
      end
    end

    desc 'user_signup'
    params do
      requires :phone_number, type: String, desc: 'Phone Number'
    end

    post 'user_signup' do
      user = User.where(phone_number: params[:phone_number].gsub(/[^0-9+]/, '')).first
      if user.present?
        error!({ error: "phone number already exist."},401)
        return
      end

      user = User.new(phone_number: permitted_params[:phone_number].gsub(/[^0-9+]/, ''), 
                    user_name: permitted_params[:phone_number].gsub(/[^0-9]/, ''),
                    last_used: Time.now)
      if user.save
        MyUserSerializer.new(user, root: 'user').as_json
      else
        error!({error: user.errors.full_messages.first},401)
      end

    end

    desc 'edit_profile'
    params do
      requires :auth_token, type: String, desc: 'Auth Token'
      optional :gender, type: String, values: User.genders.keys
      optional :first_name, type: String, desc: 'First Name'
      optional :last_name, type: String, desc: 'Last Name'
      optional :user_name, type: String, desc: 'User Name'
      optional :bio, type: String, desc: 'Bio'
      optional :latitude, type: String, desc: 'Latitude'
      optional :longitude, type: String, desc: 'Longitude'
      optional :dob, type: String, desc: 'Date of Birth'
    end
    post 'edit_profile' do
      user = User.where(authentication_token: params[:auth_token]).first
      if user.present?
        permitted_params.delete :auth_token
        age = 20
        if permitted_params[:dob].present?
          permitted_params[:dob] = DateTime.strptime(permitted_params[:dob].to_s,'%s').to_date
          now = Time.now.utc.to_date
          age = now.year - permitted_params[:dob].year - ((now.month > permitted_params[:dob].month || (now.month == permitted_params[:dob].month && now.day >= permitted_params[:dob].day)) ? 0 : 1)
        else
          permitted_params.delete :dob
        end
        if age >= 18
          if params[:gender].present? && user.gender.nil?
            user.set_gender_priority(params[:gender])
          end
          user.update!(permitted_params)
          MyUserSerializer.new(user, root: 'user').as_json
        else
          error!('You must be 18+ to Continue', 401)
        end
      else
        error!('User doesnot exist with given Auth Token', 401)
      end
    end

    desc 'Return user setting'
    params do
      requires :auth_token, type: String, desc: 'Auth Token'
    end
    get 'my_setting' do
      user = User.where(authentication_token: params[:auth_token]).first
      user.setting
    end

    desc 'edit_setting'
    params do
      requires :auth_token, type: String, desc: 'Auth Token'
      optional :everyone, type: Boolean
      optional :male_only, type: Boolean
      optional :female_only, type: Boolean
      optional :min_age, type: Integer, desc: 'Minimum Age'
      optional :max_age, type: Integer, desc: 'Maximum Age'
      optional :group_member_count, type: Integer, desc: 'Group Member Count'
      optional :max_distace, type: Integer, desc: 'Maximum Distance'
      optional :general, type: Boolean, desc: 'General Notifications From Admin'
      optional :friendship, type: Boolean, desc: 'Friendship Notifications'
      optional :match, type: Boolean, desc: 'Match Notifications'
      optional :group, type: Boolean, desc: 'Group Notifications'
      optional :chat, type: Boolean, desc: 'Chat Notifications'

    end
    post 'edit_setting' do
      user = User.where(authentication_token: params[:auth_token]).first
      if user.present?
        permitted_params.delete :auth_token
        setting = user.setting
        setting.update(permitted_params)
        setting
      else
        error!('User doesnot exist with given Auth Token', 401)
      end
    end

    desc 'Delete user account'
    params do
      requires :auth_token, type: String, desc: 'Auth Token'
      optional :reason, type: String, desc: 'Reason'
    end
    delete 'delete_account' do
      user = User.find_by(authentication_token: params[:auth_token])
      if user.present?
        group = user.groups.joined_group.first
        error!('You have to leave group first', 401) if group.present? && group.active?
        FeedBack.create(reason: permitted_params[:reason], phone_number: permitted_params[:phone_number], first_name: permitted_params[:permitted_params])
        user.destroy
      else
        error!('User doesnot exist with given Auth Token', 401)
      end
    end

    desc 'Report user'
    params do
      requires :auth_token, type: String, desc: 'Auth Token'
      requires :user_id, type: Integer, desc: 'User ID to be reported'
      requires :reason, type: String, desc: 'Reason'
      optional :image, type: File, desc: 'Image'
    end
    post 'report' do
      reporter = User.find_by(authentication_token: params[:auth_token])
      user = User.find params[:user_id]
      if reporter.present?
        report = reporter.reports.new(reason: params[:reason], user_id: user.id)
        report.image = params[:image] if params[:image].present?
        report.save
        render :message => "Reported successfully".as_json
      else
        error!('User doesnot exist with given Auth Token', 401)
      end
    end

    desc 'send message invite'
    params do
      requires :auth_token, type: String, desc: 'Auth Token'
      requires :phone_number, type: String, desc: 'Phone Number'
      requires :link, type: String, desc: 'link'

    end
    post 'send_message_invite' do
      user = User.where(authentication_token: params[:auth_token]).first
      link = params.link
      if user.present?
          TwilioClient.new.send_text(user, params[:phone_number], link)
          render :message => "Invite Sent".as_json
      else
        error!('User doesnot exist with given Auth Token', 401)
      end
    end

    desc 'Check Ios Version'
    params do
      requires :ios_version, type: String, desc: 'iOS Version'
    end
    get 'check_ios_version' do
      admin = Admin.first
      render :is_valid => (params[:ios_version].to_f >= admin.ios_version ).as_json
    end

  end
end
