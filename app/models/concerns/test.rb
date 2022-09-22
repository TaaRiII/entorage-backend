class Test
  def self.genrate_fake_users
    authentication_token = 1
    latitude = 41.44430
    longitude = -71.5317
    genders = ['male', 'female']
    Faker::Config.locale = 'en-US'
    group_statuses_ids = GroupStatus.pluck(:id)
    photos = ["https://bestcellphonespyapps.com/wp-content/uploads/2017/09/pexels-photo-220453-1-1001x1024.jpeg",
              "https://pbs.twimg.com/profile_images/748593045566853124/9DDVz0uT_400x400.jpg",
              "https://fiverr-res.cloudinary.com/images/t_main1,q_auto,f_auto/gigs/128262653/original/8c2ec2da2e21f8c62739c9f93ea22de7b401bf16/generate-100-very-realistic-yet-fake-profile-pictures.jpg",
              "https://www.whatsappprofiledpimages.com/wp-content/uploads/2018/07/facebook-profile-pic99.jpg",
              "https://mugs11.files.wordpress.com/2013/04/mtb.jpg",
              "https://www.nydailynews.com/resizer/6U_b8za00QSB2uNJQkbJaO1FTUE=/800x599/top/arc-anglerfish-arc2-prod-tronc.s3.amazonaws.com/public/BKLFDK23NWO2FVA2GGWE2C4W7E.jpg",
              "https://www.new-dating.com/rus/scammers/1576.jpg",
              "https://s3-media4.fl.yelpcdn.com/bphoto/O04-RgzqavBrnT6ZuacMDQ/o.jpg",
              "https://cdn.theconversation.com/avatars/152518/width170/image-20160503-19841-1aat3a7.jpg"]

    1.upto(500) do |i|
      user_ids = []
      1.upto(3) do |j|
        first_name   = Faker::Name.unique.first_name
        last_name    = Faker::Name.unique.last_name
        phone_number = Faker::Base.unique.numerify('+1###########')
        if j%2 == 0
          new_latitude = latitude + rand(0.0000..0.0999).round(4)
          new_longitude = longitude - rand(0.0000..0.0999).round(4)
        else
          new_latitude = latitude - rand(0.0000..0.0999).round(4)
          new_longitude = longitude + rand(0.0000..0.0999).round(4)
        end
        user = User.create!(phone_number: phone_number, latitude: new_latitude, longitude: new_longitude, user_name: "#{first_name}#{first_name}#{rand(1..100000)}" , first_name: first_name, last_name: last_name, dob: Date.today - rand(19..29).years, gender: genders.sample)
        user.authentication_token= authentication_token
        user.save
        authentication_token +=1
        user.photos.create(image: URI.parse(photos.sample), is_primary: true, order: 1)
        user_ids << user.id
        # random = rand(5..10)
        # sleep(random)
      end
      current_user = User.find(user_ids[0])
      friend = User.find(user_ids[1])

      friendship = current_user.friendships.where(friend_id: friend.id).first_or_initialize
      friendship.status = 'match'
      friendship.save

      inverse_friendship = friend.friendships.where(friend_id: current_user.id).first_or_initialize
      inverse_friendship.status = 'match'
      inverse_friendship.save

      friend = User.find(user_ids[2])

      friendship = current_user.friendships.where(friend_id: friend.id).first_or_initialize
      friendship.status = 'match'
      friendship.save

      inverse_friendship = friend.friendships.where(friend_id: current_user.id).first_or_initialize
      inverse_friendship.status = 'match'
      inverse_friendship.save

      group = current_user.group_creations.create(group_status_id: group_statuses_ids.sample)
      current_user.update_column(:creator, true)
      user_ids.each do |friend_id|
        user_group = group.user_groups.where(user_id: friend_id).first_or_create
        user_group.update_column(:status, 'joined')
      end
      group.handle_group_status

      group.set_coordinates
      group.set_name
      group.set_age_gender_and_count
    end
  end
end