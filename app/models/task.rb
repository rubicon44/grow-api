class Task < ApplicationRecord
  # include ActiveModel::Serializers::JSON
  before_create :set_untitled
  before_update :set_untitled
  belongs_to :user
  has_many :likes, dependent: :destroy
  has_many :liked_users, through: :likes, source: :user

  private

  def set_untitled
    if self.title.blank?
      self.title = "無題"
    end
  end
end
