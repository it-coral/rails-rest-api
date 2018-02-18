module Groups
  module Relations
    extend ActiveSupport::Concern

    included do
      belongs_to :organization
      has_many :group_users
      has_many :users, through: :group_users
      has_many :courses
      has_many :lessons, through: :courses
      has_many :attachments, as: :attachmentable
    end

    module ClassMethods
    end
  end
end
