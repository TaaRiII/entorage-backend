class Matches < Grape::API
  include Authentication
  include Pagination
  resource :matches do
    desc 'Find Groups To Match'
    params do
      requires :auth_token, type: String, desc: 'Auth Token'
      requires :gender, type: String, values: ["male", "female", "other"], desc: ' type'

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

      order_gender_sql = ""
      gender_order_preferance = nil
      if setting.male_only
        gender_order_preferance = [0,3,1,2]
      elsif setting.female_only
        gender_order_preferance = [1,3,0,2]
      end

      if gender_order_preferance.present?
        order_gender_sql = Arel.sql(
          "CASE WHEN gender = #{gender_order_preferance[0]} THEN 0 " \
            "WHEN gender = #{gender_order_preferance[1]} THEN 1 " \
            "WHEN gender = #{gender_order_preferance[2]} THEN 2 " \
            "ELSE 3 END"
        )
      end

      group_users_count = 2
      if group.present?
        latitude  = group.latitude
        longitude = group.longitude
        already_liked_or_matched_id = (group.matches.where(status: [0,1,3,4,5,6]).pluck(:matcher_id)  + current_user.matches.where(status: [2]).pluck(:matcher_id)).uniq
        group_users_count = group.user_groups.where(status: "joined").count
      end

      group_order_counts = [2,3,4]
      if group_users_count == 4
        group_order_counts == [4,3, 2]
      elsif group_users_count == 3
        group_order_counts = [3, 4, 2]
      end

      order_user_count_sql = Arel.sql(
        "CASE WHEN users_count = #{group_order_counts[0]} THEN 0 " \
          "WHEN users_count = #{group_order_counts[1]} THEN 1 " \
          "ELSE 2 END"
      )

      # .where("min_age >=? AND max_age <=?", setting.min_age, setting.max_age)
      order_age_sql = Arel.sql(
        "CASE WHEN min_age >= #{setting.min_age} AND max_age <= #{setting.max_age} THEN 0 " \
          "ELSE 1 END"
      )

      blocked_group_ids = Group.joins(:users).joined_group.where(users: {id: blocked_users}).pluck(:id)

      mendetary_excluded_group_ids = (already_liked_or_matched_id + blocked_group_ids).uniq
      # all_excluded_group_ids = mendetary_excluded_group_ids + group_users_count + gender_query

      groups = Group.includes(:group_status, :users)
                    .where(status: 'active')
                    .where(gender: params[:gender])
                    .where.not(id: mendetary_excluded_group_ids)
                    .order(order_gender_sql).order(order_user_count_sql)
                    .order(spot_light_enabled: :desc).order(order_age_sql)
                    .near([latitude, longitude], setting.max_distace)
                    .page(params[:page]).per(params[:per_page])

      # spotligh_groups = Group.where(status: 'active', spot_light_enabled: true)
      #                       .where("min_age >=? AND max_age <=?", setting.min_age, setting.max_age)
      #                       .where(gender_query)
      #                       .where("groups.users_count =?", group_users_count)
      #                       .where.not(id: mendetary_excluded_group_ids)
      #                       .near([latitude, longitude], setting.max_distace)

      # preferred_groups = Group.includes(:group_status, :users)
      #               .where(status: 'active')
      #               .where("min_age >=? AND max_age <=?", setting.min_age, setting.max_age)
      #               .where(gender_query)
      #               .where("groups.users_count =?", group_users_count)
      #               .where.not(id: mendetary_excluded_group_ids)
      #               .near([latitude, longitude], setting.max_distace)

      # other_preferred_groups1 = Group.includes(:group_status, :users).where(status: 'active')
      #       .where.not(id: mendetary_excluded_group_ids)
      #       .where.not(id: spotligh_groups.select(:id) + preferred_groups.select(:id))
      #       .where(gender_query)
      #       .where("groups.users_count =?", group_order_counts[0])
      #       .near([latitude, longitude], setting.max_distace)

      # other_preferred_groups2 = Group.includes(:group_status, :users).where(status: 'active')
      #       .where.not(id: mendetary_excluded_group_ids)
      #       .where.not(id: spotligh_groups.select(:id) + preferred_groups.select(:id) + other_preferred_groups1.select(:id))
      #       .where(gender_query)
      #       .where("groups.users_count =?", group_order_counts[1])
      #       .near([latitude, longitude], setting.max_distace)

      # other_groups = Group.includes(:group_status, :users).where(status: 'active')
      #       .where.not(id: mendetary_excluded_group_ids)
      #       .where.not(id: spotligh_groups.select(:id) + preferred_groups.select(:id) + other_preferred_groups1.select(:id) + other_preferred_groups2.select(:id))
      #       .near([latitude, longitude], setting.max_distace)

      # records = spotligh_groups + preferred_groups + other_preferred_groups1 + other_preferred_groups2 + other_groups
      # records = Kaminari.paginate_array(records).page(params[:page]).per(params[:per_page])
      serializer = ActiveModel::ArraySerializer.new(groups.shuffle , each_serializer: GroupGeocoderSerializer, root: false)
      # serializer = ActiveModel::ArraySerializer.new(pagination , each_serializer: GroupGeocoderSerializer, root: false)
      { groups: serializer, pagination: pagination_dict(groups)}
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
      match.instant = true
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
