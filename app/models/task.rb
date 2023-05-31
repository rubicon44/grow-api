# frozen_string_literal: true

# TODO: Fat Modelの解消
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
    return if notification_like_exists?(current_user.id)

    notification = build_like_notification(current_user)
    save_valid_notification(notification)
  end

  private

  def notification_like_exists?(current_user_id)
    Notification.exists?(visitor_id: current_user_id, visited_id: user_id, task_id: id, action: 'like')
  end

  def build_like_notification(current_user)
    notification = current_user.active_notifications.new(
      task_id: id,
      visited_id: user_id,
      action: 'like'
    )
    notification.checked = true if notification.visitor_id == notification.visited_id
    notification
  end

  def save_valid_notification(notification)
    notification.save if notification.valid?
  end

  def set_untitled_title
    self.title = '無題' if title.blank?
  end

  def set_default_task_dates
    set_start_date_default if start_date.blank? && end_date.present?
    set_end_date_default if end_date.blank? && start_date.present?
    set_both_dates_default if start_date.blank? && end_date.blank?
  end

  def set_start_date_default
    self.start_date = (Date.parse(end_date) - 1.day).to_s
  end

  def set_end_date_default
    self.end_date = (Date.parse(start_date) + 1.day).to_s
  end

  def set_both_dates_default
    self.start_date = Date.current.to_s
    self.end_date = (Date.current + 1.day).to_s
  end

  def check_start_date_is_before_end_date
    return unless start_date.present? && end_date.present? && end_date < start_date

    errors.add(:end_date, ' must be after start date')
    raise ActiveRecord::RecordInvalid, self
  end
end
