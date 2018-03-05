class Attachment < ApplicationRecord
  ATTACHMENTABLES = %w[Action Course Group Lesson Organization]
  belongs_to :user
  belongs_to :organization
  belongs_to :attachmentable, polymorphic: true, optional: true

  mount_base64_uploader :file, FileUploader
end
