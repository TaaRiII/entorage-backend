class Place < ApplicationRecord
  has_many :groups

  has_attached_file :icon, styles: { medium: "300x300>", thumb: "100x100>" }, default_url: "missing_:class.png", use_timestamp: false , preserve_files: true
  validates_attachment_content_type :icon, content_type: /\Aimage\/.*\z/
end
