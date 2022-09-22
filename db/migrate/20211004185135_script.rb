class Script < ActiveRecord::Migration[5.2]
  def change
    User.all.each do |user|
      latest_id = user.devices.order(:updated_at).last.try(:id)
      user.devices.where.not(id: latest_id).delete_all
    end
  end
end
