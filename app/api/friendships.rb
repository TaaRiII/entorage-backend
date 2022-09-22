class Friendships < Grape::API
  include Authentication
  resource :friendships do
    #Direcy Friendship
    desc 'direct_friendship'
    params do
      requires :auth_token, type: String, desc: 'Auth Token'
      requires :phone_number, type: String, desc: 'Phone Number'
    end
    post 'direct_friendship' do
      friend = User.where(phone_number: params[:phone_number]).only_unbanned.first
      error!('User doesnot exist, send invite', 401) if friend.nil?

      friendship = current_user.friendships.where(friend_id: friend.id).first_or_initialize
      friendship.status = 'match'
      friendship.save

      inverse_friendship = friend.friendships.where(friend_id: current_user.id).first_or_initialize
      inverse_friendship.status = 'match'
      inverse_friendship.save

      FriendshipUserSerializer.new(friendship)
    end

    desc 'direct_friendship_by_id'
    params do
      requires :auth_token, type: String, desc: 'Auth Token'
      requires :id, type: Integer, desc: 'User ID'
    end
    post 'direct_friendship_by_id' do
      friend = User.where(id: params[:id]).only_unbanned.first
      error!('User doesnot exist, send invite', 401) if friend.nil?

      friendship = current_user.friendships.where(friend_id: friend.id).first_or_initialize
      friendship.status = 'match'
      friendship.save

      inverse_friendship = friend.friendships.where(friend_id: current_user.id).first_or_initialize
      inverse_friendship.status = 'match'
      inverse_friendship.save

      FriendshipUserSerializer.new(friendship)
    end

    #multiple_Direcy Friendship
    desc 'multiple_direct_friendship'
    params do
      requires :auth_token, type: String, desc: 'Auth Token'
      requires :phone_number, type: String, desc: 'Phone Number'
    end
    post 'multiple_direct_friendship' do
      param=params[:phone_number].split(",")
      param.each do |p_number|
        next if p_number == current_user.phone_number
        friend = User.where(phone_number: p_number).only_unbanned.first
        error!('User doesnot exist, send invite', 401) if friend.nil?

        friendship = current_user.friendships.where(friend_id: friend.id).first_or_initialize
        friendship.status = 'match'
        friendship.save

        inverse_friendship = friend.friendships.where(friend_id: current_user.id).first_or_initialize
        inverse_friendship.status = 'match'
        inverse_friendship.save

        FriendshipUserSerializer.new(friendship)
      end
    end
    #Request for Friendship
    desc 'request'
    params do
      requires :auth_token, type: String, desc: 'Auth Token'
      requires :friend_id, type:  Integer, desc: 'Friend ID'
    end
    post 'request' do
      friend =  User.where(id: permitted_params[:friend_id]).only_unbanned.first
      error!("User doesnot exists", 401) if friend.nil?
      friendship = current_user.friendships.where(friend_id: friend.id).first_or_initialize
      friendship.status  = 'requested'
      friendship.save

      inverse_friendship = friend.friendships.where(friend_id: current_user.id).first_or_initialize
      inverse_friendship.status  = 'accept'
      inverse_friendship.save
      FriendshipUserSerializer.new(friendship)
    end

    desc 'accept'
    params do
      requires :auth_token, type: String, desc: 'Auth Token'
      requires :friend_id, type:  Integer, desc: 'Friend ID'
    end
    post 'accept' do
      friend =  User.where(id: permitted_params[:friend_id]).only_unbanned.first
      error!("User doesnot exists", 401) if friend.nil?
      inverse_friendship = current_user.inverse_friendships.where(user_id: permitted_params[:friend_id], status: 'requested').first
      if inverse_friendship.present?
        friendship = current_user.friendships.where(friend_id: friend.id).first_or_initialize
        friendship.status = 'match'
        friendship.save
        inverse_friendship.update_column(:status, 'match')
        FriendshipUserSerializer.new(friendship)
      else
        error!('No request found', 401)
      end
    end

    #Friendship Status
    desc 'status'
    params do
      requires :auth_token, type: String, desc: 'Auth Token'
      requires :friend_id, type:  Integer, desc: 'Block ID'
    end
    get 'status' do
      friend =  User.where(id: permitted_params[:friend_id]).only_unbanned.first
      error!("User doesnot exists", 401) if friend.nil?
      friendship = current_user.friendships.where(friend_id: friend.id).first
      status = "request"
      if friendship.present?
       status = friendship.status
      end
      render :status => status.as_json
    end

    #Block a User
    desc 'Block'
    params do
      requires :auth_token, type: String, desc: 'Auth Token'
      requires :friend_id, type:  Integer, desc: 'Block ID'
      optional :reason, type: String, desc: 'Reason'
      optional :image, type: File, desc: 'Image'
    end
    post 'block' do
      friend =  User.where(id: permitted_params[:friend_id]).only_unbanned.first
      error!("User doesnot exists", 401) if friend.nil?
      group = current_user.groups.joined_group.first
      if group.present?
        if group.users.joined_group.where(id: friend.id).present?
          error!("#{friend.full_name} is member of your group, you have to leave group first to perform block operation", 401)
        elsif group.users.pending_group.where(id: friend.id).present?
          error!("#{friend.full_name} being invited to join your group, you have to cancel invitation first to perform block operation", 401)
        end
      end
      friendship = current_user.friendships.where(friend_id: friend.id).first_or_initialize
      friendship.status = 'block'
      friendship.save

      inverse_friendship = friend.friendships.where(friend_id: current_user.id).first_or_initialize
      inverse_friendship.status = 'blocked'
      inverse_friendship.save

      report = current_user.reports.new(reason: params[:reason], user_id: friend.id, report_type: 'block')
      report.image = params[:image] if params[:image].present?
      report.save

      FriendshipUserSerializer.new(friendship)
    end

    #unBlock a User
    desc 'Unblock User(s)'
    params do
      requires :auth_token, type: String, desc: 'Auth Token'
      requires :blocked_user_ids, type:  String, desc: 'like [1,2,3]'
    end
    post 'unblock' do
      blocked_user_ids = JSON.parse(permitted_params[:blocked_user_ids])
      current_user.friendships.where(status: 'block',friend_id: blocked_user_ids).destroy_all
      current_user.inverse_friendships.where(status: 'blocked', user_id: blocked_user_ids).destroy_all
      friendships = current_user.friendships.joins(:user).where("users.is_blocked=? AND friendships.status=?", false, 2)
      friendships = ActiveModel::ArraySerializer.new(friendships, each_serializer: FriendshipUserSerializer).as_json
    end

    #Get Friendes
    desc 'friends'
    params do
      requires :auth_token, type: String, desc: 'Auth Token'
    end
    get 'friendes' do
      friendships = current_user.friendships.joins(:user).where("users.is_blocked=? AND friendships.status=?", false, 1)
      friendships = ActiveModel::ArraySerializer.new(friendships, each_serializer: FriendshipUserSerializer).as_json
    end

    #Get Friendes
    desc 'all friends and requests (All matched only)'
    params do
      requires :auth_token, type: String, desc: 'Auth Token'
      requires :phone_numbers, type: String, desc: "phone_numbers like [1,2,3]"
      optional :direct_friendship, type: Boolean, desc: 'Make direct friend or not, nil considered as true'
      optional :multiple_direct_friendship, type: Boolean, desc: 'Make direct friend or not, nil considered as true'
    end
    post 'all_friends_and_requests' do
      phone_numbers = JSON.parse(permitted_params[:phone_numbers])
      phone_numbers.map! {|phone_number| PhonyRails.normalize_number(PhonyRails.normalize_number(phone_number), default_country_code: 'US')}

      friend_ids = User.where(phone_number: phone_numbers).only_unbanned.pluck(:id)
      friendships =  current_user.friendships.joins(:user).where(friendships: {status: 1}, users: {is_blocked: false})

      users_with_no_match_relation = friend_ids - friendships.pluck(:friend_id)
      blocked_user_ids = current_user.friendships.where(friendships: {status: 2}).pluck(:friend_id) + current_user.inverse_friendships.where(friendships: {status: 2}).pluck(:user_id) + User.where(is_blocked: true).pluck(:id)  + [current_user.id]
      unfriend_user_ids =  current_user.friendships.where(friendships: {status: 5}).pluck(:friend_id) + current_user.inverse_friendships.where(friendships: {status: 5}).pluck(:user_id)
      if params[:direct_friendship].nil? || params[:multiple_direct_friendship]
        users = User.where(id: users_with_no_match_relation).where.not(id: blocked_user_ids)
        users.each do |friend|
          next if unfriend_user_ids.include?(friend.id)
          friendship = current_user.friendships.where(friend_id: friend.id).first_or_initialize
          friendship.status = 'match'
          friendship.save

          inverse_friendship = friend.friendships.where(friend_id: current_user.id).first_or_initialize
          inverse_friendship.status = 'match'
          inverse_friendship.save
        end
      end

      #update with newly added friendships
      friendships =  current_user.friendships.joins(:user).where(friendships: {status: 1}, users: {is_blocked: false})

      ActiveModel::ArraySerializer.new(friendships, each_serializer: FriendshipUserSerializer).as_json
      # users = ActiveModel::ArraySerializer.new(users, context: {status: 'no relation'}, each_serializer: UserFriendshipSerializer).as_json
      # friendships + users

    end

    #Get Friendes
    desc 'all friends (global) and not exist on server (by contacts)'
    params do
      requires :auth_token, type: String, desc: 'Auth Token'
      requires :phone_numbers, type: String, desc: "phone_numbers like [1,2,3]"
    end
    post 'friends_and_no_relation' do
      phone_numbers = JSON.parse(permitted_params[:phone_numbers])
      normalized_phone_numbers = []
      phone_numbers.map {|phone_number| normalized_phone_numbers<< PhonyRails.normalize_number(PhonyRails.normalize_number(phone_number), default_country_code: 'US')}

      existing_phone_numbers = User.where(phone_number: normalized_phone_numbers).only_unbanned.pluck(:phone_number)
      non_existing_phone_numbers = []
      normalized_phone_numbers.each_with_index do |nph,i|
        if existing_phone_numbers.exclude?(nph)
          non_existing_phone_numbers << phone_numbers[i]
        end
      end

      friendships = current_user.friendships.joins(:user).where("users.is_blocked=? AND friendships.status=?", false, 1)
      response = {
                  friendships:  ActiveModel::ArraySerializer.new(friendships, each_serializer: FriendshipUserSerializer).as_json,
                  non_existing: non_existing_phone_numbers
                 }
      response

    end

    #Get Friendes
    desc 'all users who sent request to me ( I sent as well now)'
    params do
      requires :auth_token, type: String, desc: 'Auth Token'
    end
    post 'received_requests' do
      friendships = current_user.friendships.joins(:user).where("users.is_blocked=? AND friendships.status IN (?)", false, [0,3]) #+ current_user.inverse_friendships.joins(:user).where("users.is_blocked=? AND friendships.status=?", false, 0)
      ActiveModel::ArraySerializer.new(friendships, each_serializer: FriendshipUserSerializer).as_json
    end

    #Get Friendes
    desc 'users exist on server but no relation yet'
    params do
      requires :auth_token, type: String, desc: 'Auth Token'
    end
    post 'no_relation' do
      friend_ids =  current_user.friendships.select(:friend_id)
      no_relation = User.where.not(id: friend_ids)
      ActiveModel::ArraySerializer.new(no_relation, context: {status: 'no_relation'}, each_serializer: UserFriendshipSerializer).as_json

    end

    #UnFriend
    desc 'Unfriend'
    params do
      requires :auth_token, type: String, desc: 'Auth Token'
      requires :friend_id, type:  Integer, desc: 'Unfriend ID'
    end
    post 'unfriend' do
      friend =  User.where(id: permitted_params[:friend_id]).only_unbanned.first
      error!("User doesnot exists", 401) if friend.nil?
      friendship = current_user.friendships.where(friend_id: friend.id).first
      inverse_friendship = current_user.inverse_friendships.where(friend_id: friend.id).first
      friendship.update_columns(status: 'unfriend') if friendship.present?
      inverse_friendship..update_columns(status: 'unfriend') if inverse_friendship.present?
      render :message => "Unfriend Successfully".as_json
    end

    #Get Friendes
    desc 'blocked users'
    params do
      requires :auth_token, type: String, desc: 'Auth Token'
    end
    get 'blocked' do
      friendships = current_user.friendships.joins(:user).where("users.is_blocked=? AND friendships.status=?", false, 2)
      friendships = ActiveModel::ArraySerializer.new(friendships, each_serializer: FriendshipUserSerializer).as_json
    end
  end
end
