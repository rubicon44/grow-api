class Task < ApplicationRecord
  # include ActiveModel::Serializers::JSON
  before_create :set_untitled
  before_create :set_task_date
  before_update :set_untitled
  before_update :set_task_date
  belongs_to :user
  has_many :likes, dependent: :destroy
  has_many :liked_users, through: :likes, source: :user

  has_many :notifications, dependent: :destroy

  def create_notification_like!(current_user)
    # すでに「いいね」されているか検索
    temp = Notification.where(['visitor_id = ? and visited_id = ? and task_id = ? and action = ? ', current_user.id,
                               user_id, id, 'like'])
    # いいねされていない場合のみ、通知レコードを作成
    return unless temp.blank?

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

  def set_untitled
    if self.title.blank?
      self.title = "無題"
    end
  end

  def set_task_date
    if self.start_date.blank?
      self.start_date = "#{Date.current}"
    end

    if self.end_date.blank?
      self.end_date = "#{Date.tomorrow}"
    end
  end
end
