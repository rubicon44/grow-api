# frozen_string_literal: true

module V1
  class NotificationsController < ApiController
    def index
      current_user = User.find(params[:user_id])

      Notification.mark_notifications_as_read(current_user)
      notifications = Notification.get_unread_notifications(current_user)
      follow_visitors, like_visitors = Notification.generate_notification_users(current_user)

      render_notifications(follow_visitors, like_visitors, notifications)
    end

    private

    def render_notifications(follow_visitors, like_visitors, notifications)
      render json: {
        follow_visitors: UserSerializer.serialize_users_collection(follow_visitors),
        like_visitors: UserSerializer.serialize_users_collection(like_visitors),
        notifications: NotificationSerializer.serialize_notifications_collection(notifications)
      }, status: :ok
    end
  end
end
