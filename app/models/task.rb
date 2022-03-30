class Task < ApplicationRecord
  # include ActiveModel::Serializers::JSON
  before_create :set_untitled
  before_update :set_untitled
  belongs_to :user

  private

  def set_untitled
    if self.title.blank?
      self.title = "無題"
    end
  end
end
