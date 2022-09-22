class AddFieldsToGroup < ActiveRecord::Migration[5.2]
  def change
    add_column :groups, :gender, :integer
    add_column :groups, :min_age, :integer
    add_column :groups, :max_age, :integer
    add_column :groups, :users_count, :integer

    Group.all.each do |group|
      user_groups = group.user_groups.where(status: "joined")
      group.users_count = user_groups.count
      group.min_age = user_groups.joins(:user).minimum("users.age")
      group.max_age = user_groups.joins(:user).maximum("users.age")
      genders = user_groups.joins(:user).pluck("users.gender").uniq
      if genders.length == 1
        group.gender = genders[0]
      else
        group.gender = 3
      end
      group.save
    end
  end
end
