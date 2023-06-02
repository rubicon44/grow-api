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

  validate :validate_task

  def create_notification_like!(current_user)
    return if notification_like_exists?(current_user.id)

    notification = build_like_notification(current_user)
    save_valid_notification(notification)
  end

  private

  def build_like_notification(current_user)
    notification = current_user.active_notifications.new(
      task_id: id,
      visited_id: user_id,
      action: 'like'
    )
    notification.checked = true if notification.visitor_id == notification.visited_id
    notification
  end

  def notification_like_exists?(current_user_id)
    Notification.exists?(visitor_id: current_user_id, visited_id: user_id, task_id: id, action: 'like')
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

  def validate_task
    validate_title
    validate_content
    validate_status
    validate_start_date
    validate_end_date
    validate_start_date_before_end_date
  end

  def validate_title
    errors.add(:title, ' must be present') if title.blank?
    errors.add(:title, ' exceeds maximum length') if title.length > 255
  end

  def validate_content
    errors.add(:content, ' exceeds maximum length') if content.present? && content.length > 5000
  end

  def validate_status
    errors.add(:status, ' is invalid') unless [0, 1, 2, 3].include?(status)
  end

  def validate_start_date
    errors.add(:start_date, ' has invalid format') if start_date.present? && !valid_date_format?(start_date)
  end

  def validate_end_date
    errors.add(:end_date, ' has invalid format') if end_date.present? && !valid_date_format?(end_date)
  end

  def valid_date_format?(date)
    /\A\d{4}-\d{2}-\d{2}\z/.match?(date)
  end

  def validate_start_date_before_end_date
    return unless start_date.present? && end_date.present? && end_date < start_date

    errors.add(:end_date, ' must be after start date')
  end
end
