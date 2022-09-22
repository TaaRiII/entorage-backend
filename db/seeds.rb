if Admin.count == 0
  admin=Admin.new(email:'admin@admin.com',password:'12345678')
  admin.save(:validate=>false)
end


# latitude = 41.4443
# longitude = -71.5317
# Faker::Config.locale = 'en-US'
# group_statuses_ids = GroupStatus.pluck(:id)
# photos = ["https://bestcellphonespyapps.com/wp-content/uploads/2017/09/pexels-photo-220453-1-1001x1024.jpeg",
#           "https://pbs.twimg.com/profile_images/748593045566853124/9DDVz0uT_400x400.jpg",
#           "https://fiverr-res.cloudinary.com/images/t_main1,q_auto,f_auto/gigs/128262653/original/8c2ec2da2e21f8c62739c9f93ea22de7b401bf16/generate-100-very-realistic-yet-fake-profile-pictures.jpg",
#           "https://www.whatsappprofiledpimages.com/wp-content/uploads/2018/07/facebook-profile-pic99.jpg",
#           "https://mugs11.files.wordpress.com/2013/04/mtb.jpg",
#           "https://www.nydailynews.com/resizer/6U_b8za00QSB2uNJQkbJaO1FTUE=/800x599/top/arc-anglerfish-arc2-prod-tronc.s3.amazonaws.com/public/BKLFDK23NWO2FVA2GGWE2C4W7E.jpg",
#           "https://www.new-dating.com/rus/scammers/1576.jpg",
#           "https://s3-media4.fl.yelpcdn.com/bphoto/O04-RgzqavBrnT6ZuacMDQ/o.jpg",
#           "https://cdn.theconversation.com/avatars/152518/width170/image-20160503-19841-1aat3a7.jpg"]

# 1.upto(10) do |i|
#   user_ids = []
#   1.upto(3) do |j|
#     first_name   = Faker::Name.unique.first_name
#     last_name    = Faker::Name.unique.last_name
#     phone_number = Faker::Base.unique.numerify('+1###########')
#     if j%2 == 0
#       new_latitude = latitude + rand(0.0000..0.0999).round(4)
#       new_longitude = longitude - rand(0.0000..0.0999).round(4)
#     else
#       new_latitude = latitude - rand(0.0000..0.0999).round(4)
#       new_longitude = longitude + rand(0.0000..0.0999).round(4)
#     end
#     user = User.create(phone_number: phone_number, latitude: new_latitude, longitude: new_longitude, user_name: first_name, first_name: first_name, last_name: last_name)
#     # user.photos.create(image: URI.parse(photos.sample), is_primary: true, order: 1)
#     user_ids << user.id
#     random = rand(5..10)
#     sleep(random)
#   end
#   current_user = User.find(user_ids[0])
#   friend = User.find(user_ids[1])

#   friendship = current_user.friendships.where(friend_id: friend.id).first_or_initialize
#   friendship.status = 'match'
#   friendship.save

#   inverse_friendship = friend.friendships.where(friend_id: current_user.id).first_or_initialize
#   inverse_friendship.status = 'match'
#   inverse_friendship.save

#   friend = User.find(user_ids[2])

#   friendship = current_user.friendships.where(friend_id: friend.id).first_or_initialize
#   friendship.status = 'match'
#   friendship.save

#   inverse_friendship = friend.friendships.where(friend_id: current_user.id).first_or_initialize
#   inverse_friendship.status = 'match'
#   inverse_friendship.save

#   group = current_user.group_creations.create(group_status_id: group_statuses_ids.sample)
#   current_user.update_column(:creator, true)
#   user_ids.each_with_index do |friend_id, i|
#     user_group = group.user_groups.where(user_id: friend_id).first_or_create
#     if friend_id == current_user.id || i == 2
#       user_group.update_column(:status, 'joined')
#     end
#   end

#   group.set_coordinates(current_user)
#   group.set_name
# end

# User.all.each_with_index do |user, index|
#   user.authentication_token = index+1
#   user.save
# end

#
# User.all.each do |user|
#   user.dob = Date.today - rand(19..29).years
#   user.gender = 'male'
#   user.save
# end

# u1 = User.create(phone_number: 1, latitude: '31.456887', longitude: '74.305216')
# u1.update_attributes(authentication_token: "1")
# sleep(5)
# u2 = User.create(phone_number: 2, latitude: '31.486349', longitude: '74.292931')
# u2.update_attributes(authentication_token: "2")
# sleep(6)
# u3 = User.create(phone_number: 3, latitude: '31.506349', longitude: '74.282931')
# u3.update_attributes(authentication_token: "3")
# sleep(10)
# u3 = User.create(phone_number: 4, latitude: '31.526349', longitude: '74.272931')
# u3.update_attributes(authentication_token: "4")
# sleep(3)
# u3 = User.create(phone_number: 5, latitude: '31.546349', longitude: '74.252931')
# u3.update_attributes(authentication_token: "5")
# sleep(6)
# u3 = User.create(phone_number: 6, latitude: '31.606349', longitude: '74.202931')
# u3.update_attributes(authentication_token: "6")
# sleep(5)
# u3 = User.create(phone_number: 7, latitude: '31.656349', longitude: '74.152931')
# u3.update_attributes(authentication_token: "7")
# sleep(9)
# u3 = User.create(phone_number: 8, latitude: '31.706349', longitude: '74.102931')
# u3.update_attributes(authentication_token: "8")
# sleep(7)
# u3 = User.create(phone_number: 9, latitude: '31.756349', longitude: '74.052931')
# u3.update_attributes(authentication_token: "9")
#
#
# GroupStatus.create(name: 'test')
# GroupStatus.create(name: 'test2')
# GroupStatus.create(name: 'test3')
#
# icons = ["plans","drinks","club","concert","game","chat"]
# names = ["Default","Drinking at a Local Bar" , "Dancing at the Club" , "Lil Wayne Concert", "Superbowl XXI" , "Chat"]
# descriptions = ["Going Out" , "Grabbing Drinks" , "Hitting the Club" , "Attending the Concert" , "Watching the Game" , "chat"]
#
# 0.upto(4).each do |i|
#   GroupStatus.create(name: names[i], icon: icons[i], description: descriptions[i])
# end


# Group.all.each do |group|
#   users = User.where(group_id: group.id)
#   users.each_with_index do |user, i|
#     user_group = group.user_groups.new(user_id: user.id, status: 'joined')
#     user_group.save
#     group.update_attributes(creator_id: user.id)  if i.zero?
#
#   end
# end
