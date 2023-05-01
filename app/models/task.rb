class Task < ApplicationRecord
  before_create :set_untitled_title
  before_create :set_default_task_dates
  before_update :set_untitled_title
  before_update :set_default_task_dates

  belongs_to :user
  has_many :likes, dependent: :destroy
  has_many :liked_users, through: :likes, source: :user
  has_many :notifications, dependent: :destroy

  validates :title, presence: true

  def create_notification_like!(current_user)
    # すでに「いいね」されているか検索(いいねされていない場合のみ、通知レコードを作成)
    return unless Notification.where(visitor_id: current_user.id, visited_id: user_id, task_id: id, action: 'like').blank?

    notification = current_user.active_notifications.new(
      task_id: id,
      visited_id: user_id,
      action: 'like'
    )
    # 自分の投稿に対するいいねの場合は、通知済みとする
    notification.checked = true if notification.visitor_id == notification.visited_id
    notification.save if notification.valid?
  end

  private

  def set_untitled_title
    self.title = "無題" if title.blank?
  end

  def set_default_task_dates
    self.start_date = Date.current.to_s if start_date.blank?
    self.end_date = Date.tomorrow.to_s if end_date.blank?
  end
end