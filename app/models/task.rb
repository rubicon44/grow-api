class Task < ApplicationRecord
  before_create :set_untitled

  private

  def set_untitled
    if self.title.blank?
      self.title = "無題"
    end
  end
end
