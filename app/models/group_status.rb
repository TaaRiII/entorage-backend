class GroupStatus < ApplicationRecord
  has_many :groups
  belongs_to :user, optional: true

  has_attached_file :icon, styles: { medium: "300x300>", thumb: "100x100>" }, default_url: "missing_:class.png", use_timestamp: false , preserve_files: true
  validates_attachment_content_type :icon, content_type: /\Aimage\/.*\z/

  enum status_type: [:default, :custom, :place]

  acts_as_list scope: [:status_type]

  # validation
  validates :name, presence: true

  # geocode
  reverse_geocoded_by :latitude, :longitude

  # soft delete
  include Discard::Model
end
