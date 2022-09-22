class Report < ApplicationRecord
  #callbacks
  belongs_to :user
  belongs_to :reporter, :class_name => "User"

  has_attached_file :image, default_url: "missing_:class.png", use_timestamp: false , preserve_files: true
  validates_attachment_content_type :image, content_type: /\Aimage\/.*\z/

  #enum
  enum status: [:pending, :ignore, :ban]
  enum report_type: [:report, :block]

  #callbacks
  before_save :rename_image
  before_save :change_user_status, if: ->(obj){ obj.status_changed? }

  def rename_image
    if image_file_name.present? && image_file_name_changed?
      extension = File.extname(image_file_name).downcase
      self.image.instance_write :file_name, (0...10).map { ('a'..'z').to_a[rand(26)] }.join +  "#{extension}"
    end
  end

  def change_user_status
    if ban?
      self.user.update_attributes(is_blocked: true)
    else
      self.user.update_attributes(is_blocked: false)
    end
  end
end
