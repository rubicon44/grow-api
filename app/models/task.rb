# frozen_string_literal: true

class Task < ApplicationRecord
  before_validation :set_default_task_dates
  before_create :set_untitled_title
  before_update :set_untitled_title

  belongs_to :user
  has_many :likes, dependent: :destroy
  has_many :liked_users, through: :likes, source: :user
  has_many :notifications, dependent: :destroy

  validates :title, presence: true, length: { maximum: 255 }
  validates :content, length: { maximum: 5000 }
  validates :status, inclusion: { in: [0, 1, 2, 3] }
  validates :start_date, format: { with: /\A\d{4}-\d{2}-\d{2}\z/ }
  validates :end_date, format: { with: /\A\d{4}-\d{2}-\d{2}\z/ }
  validate :check_start_date_is_before_end_date

  def create_notification_like!(current_user)
    # すでに「いいね」されているか検索(いいねされていない場合のみ、通知レコードを作成)
    return if Notification.where(visitor_id: current_user.id, visited_id: user_id, task_id: id,
                                 action: 'like').present?

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
    self.title = '無題' if title.blank?
  end

  def set_default_task_dates
    if start_date.blank? && end_date.present?
      self.start_date = (Date.parse(end_date) - 1.day).to_s
    elsif end_date.blank? && start_date.present?
      self.end_date = (Date.parse(start_date) + 1.day).to_s
    elsif start_date.blank? && end_date.blank?
      self.start_date = Date.current.to_s
      self.end_date = (Date.current + 1.day).to_s
    end
  end

  def check_start_date_is_before_end_date
    return unless start_date.present? && end_date.present? && end_date < start_date

    errors.add(:end_date, ' must be after start date')
    raise ActiveRecord::RecordInvalid, self
  end
end
