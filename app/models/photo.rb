class Photo < ApplicationRecord
  belongs_to :user, optional: true

  has_attached_file :image, styles: { medium: "300x300>", thumb: "100x100>" }, default_url: "missing_:class.png", use_timestamp: false , preserve_files: true
  validates_attachment_content_type :image, content_type: /\Aimage\/.*\z/

  before_save :rename_image
  before_save :mark_is_ever_primary, if: :is_primary
  after_save  :send_profile_picture_changed_notification, :mark_other_non_primary, if: :is_primary
  after_destroy :reorder 

  def rename_image
    if image_file_name.present? && image_file_name_changed?
      extension = File.extname(image_file_name).downcase
      self.image.instance_write :file_name, (0...10).map { ('a'..'z').to_a[rand(26)] }.join +  "#{extension}"
    end
  end

  def mark_is_ever_primary
    self.is_ever_primary = true
  end

  def mark_other_non_primary
    self.user.photos.where.not(id: self.id).update_all(is_primary: false)
  end

  def send_profile_picture_changed_notification
    group = self.user.groups.joined_group.first
    if group.present?
      group.send_profile_picture_changed_notification(self.user_id)
    end
  end

  def reorder
    self.user.photos.where.not(is_primary: true).each_with_index do |photo, index|
      photo.update_column(:order, index+1)
    end
  end

end
