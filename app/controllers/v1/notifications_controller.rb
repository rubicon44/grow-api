# frozen_string_literal: true

module V1
  class NotificationsController < ApiController
    def index
      current_user = User.find(params[:user_id])

      Notification.mark_notifications_as_read(current_user)
      notifications = Notification.get_unread_notifications(current_user)
      follow_visitors, like_visitors = Notification.generate_notification_users(current_user)

      render json: {
        follow_visitors: serialize_users(follow_visitors),
        like_visitors: serialize_users(like_visitors),
        notifications: serialize_notifications(notifications)
      }, status: :ok
    end

    private

    def serialize_users(users)
      ActiveModel::Serializer::CollectionSerializer.new(users, each_serializer: UserSerializer)
    end

    def serialize_notifications(notifications)
      ActiveModel::Serializer::CollectionSerializer.new(notifications, each_serializer: NotificationSerializer)
    end
  end
end
