class MatchesOld < Grape::API
  include Authentication
  include Pagination
  resource :matches_old do
    desc 'Find Groups To Match'
    params do
      requires :auth_token, type: String, desc: 'Auth Token'
      use :pagination
    end
    get 'find_groups' do
      setting = current_user.setting
      setting.max_distace = 10000
      latitude  = current_user.latitude
      longitude = current_user.longitude

      group = current_user.groups.joined_group.first
      already_liked_or_matched_id = []
      blocked_users = current_user.friendships.where(friendships: {status: 2}).pluck(:friend_id) +
                      current_user.inverse_friendships.where(friendships: {status: 2}).pluck(:user_id)  + [current_user.id]

      age_check_ids = Group.joins(:users).joined_group.where('users.age >? OR users.age < ?', setting.max_age, setting.min_age).pluck(:id).uniq

      gender_check = []
      if setting.male_only
        gender_check = Group.joins(:users).joined_group.where('users.gender !=?', 0).pluck(:id)
      elsif setting.female_only
        gender_check = Group.joins(:users).joined_group.where('users.gender !=?', 1).pluck(:id)
      end

      group_member_count_check = []

      if group.present?
        latitude  = group.latitude
        longitude = group.longitude
        already_liked_or_matched_id = (group.matches.where(status: [0,1,3,4,5,6]).pluck(:matcher_id)  + current_user.matches.where(status: [2]).pluck(:matcher_id)).uniq

        group_member_count_check = Group.joins(:users).joined_group.group('groups.id')
                                        .having("count(groups.id) != #{group.user_groups.where(status: "joined").count}").pluck(:id)
      end

      blocked_group_ids = Group.joins(:users).joined_group.where(users: {id: blocked_users}).pluck(:id)

      #all groups excluded
      # groups = []
      # other_groups = []
      mendetary_excluded_group_ids = (already_liked_or_matched_id + blocked_group_ids).uniq
      all_excluded_group_ids = mendetary_excluded_group_ids + group_member_count_check + age_check_ids + gender_check
      pagination = Group.where(status: 'active', spot_light_enabled: true)
                            .where.not(id: all_excluded_group_ids)
                            .near([latitude, longitude], setting.max_distace, order: 'random()')
                            .page(params[:page]).per(params[:per_page])
      # pagination = spotligh_groups
      pagination_type="spotlight"
      if pagination.length.zero?
        params[:page] = 1 if  params[:pagination_type] == "spotlight"
        pagination = Group.includes(:group_status, :users)
                      .where(status: 'active', spot_light_enabled: false)
                      .where.not(id: all_excluded_group_ids)
                      .near([latitude, longitude], setting.max_distace, order: 'random()').page(params[:page]).per(params[:per_page])
        # pagination = groups
        pagination_type="preferred"
        if pagination.length.zero?
          params[:page] = 1 if  params[:pagination_type] == "preferred" || params[:pagination_type] == "spotlight"
          pagination = Group.includes(:group_status, :users).where(status: 'active')
                              .where(id: gender_check + group_member_count_check + age_check_ids)
                              .where.not(id: mendetary_excluded_group_ids)
                              .near([latitude, longitude], 10000, order: 'random()').page(params[:page]).per(params[:per_page])
          # pagination = other_groups
          pagination_type="other"
        end
      end

      # serializer = ActiveModel::ArraySerializer.new(spotligh_groups + groups + other_groups , each_serializer: GroupGeocoderSerializer, root: false)
      serializer = ActiveModel::ArraySerializer.new(pagination , each_serializer: GroupGeocoderSerializer, root: false)
      { groups: serializer, pagination: pagination_dict(pagination, pagination_type)}
      # Group.where.not(id: mendetary_excluded_group_ids).page(params[:page]).per(params[:per_page])
    end

    desc 'Instant Match'
    params do
      requires :auth_token, type: String, desc: 'Auth Token'
      requires :group_id, type: String, desc: 'Group ID'
    end
    post 'instant_match' do
      group = current_user.groups.joined_group.first
      matcher = Group.find_by_id params[:group_id]
      error!('Create or join a group first', 401) if group.nil?
      error!('No Instant Match Available', 401) if group.instant_match_allow.zero? || current_user.instant_match_allow.zero?
      matcher = Match.where(group_id: matcher.id, matcher_id: group, user_id: matcher.creator_id).first_or_initialize
      matcher.status = 'like'
      matcher.save

      match = current_user.matches.where(group_id: group.id, matcher_id: permitted_params[:group_id]).first_or_initialize
      match.status = 'like'
      match.save
      group.decrement!(:instant_match_allow, 1)
      current_user.decrement!(:instant_match_allow, 1)
      match.check_match
    end

    desc 'Like Group'
    params do
      requires :auth_token, type: String, desc: 'Auth Token'
      requires :group_id, type: String, desc: 'Group ID'
    end
    post 'like_group' do
      group = current_user.groups.joined_group.first
      error!('Create or join a group first', 401) if group.nil?
      match = current_user.matches.where(group_id: group.id, matcher_id: permitted_params[:group_id]).first_or_initialize
      match.status = 'like'
      match.save
      match.check_match
    end

    desc 'Unlike Group'
    params do
      requires :auth_token, type: String, desc: 'Auth Token'
      requires :group_id, type: String, desc: 'Group ID'
    end
    post 'unlike_group' do
      group = current_user.groups.joined_group.first
      error!('Create or join a group first', 401) if group.nil?
      match = current_user.matches.where(group_id: group.id, matcher_id: permitted_params[:group_id]).first_or_initialize
      match.status = 'unlike'
      match.save
      match
      #don't block group on all unlike users
      # match.check_block

    end

    desc 'Revert Last Operation'
    params do
      requires :auth_token, type: String, desc: 'Auth Token'
      requires :group_id, type: String, desc: 'Group ID'
    end
    post 'revert' do
      group = current_user.groups.joined_group.first
      error!('Create or join a group first', 401) if group.nil?
      match = current_user.matches.where(group_id: group.id, matcher_id: permitted_params[:group_id]).first
      match.destroy if match.present?
      render :message => "Reverted Successfully".as_json

    end


    desc 'my_matches'
    params do
      requires :auth_token, type: String, desc: 'Auth Token'
    end
    get 'my_matches' do
      group = current_user.groups.joined_group.first
      if group.present?
        inactive_matcher_ids = Group.where(status: 'inactive').select(:id)
        matches = group.matches.where(status: 'match').where.not(matcher_id: inactive_matcher_ids)
        ActiveModel::ArraySerializer.new(matches, each_serializer: MatchSerializer, context: { user_id: current_user.id }).as_json
      else
        render matches: []
      end

    end

    desc 'Unmatch Group'
    params do
      requires :auth_token, type: String, desc: 'Auth Token'
      requires :group_id, type: String, desc: 'Group ID'
    end
    delete 'unmatch_group' do
      group = current_user.groups.joined_group.first
      error!('Create or join a group first', 401) if group.nil?
      Match.where(group_id: group.id, matcher_id: permitted_params[:group_id]).or(Match.where(group_id: permitted_params[:group_id], matcher_id: group.id)).destroy_all
      render :message => "Group Unmatched".as_json
    end

  end
end
