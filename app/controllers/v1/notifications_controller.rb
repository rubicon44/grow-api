module V1
  class NotificationsController < ApiController
    def index
      current_user = User.find(params[:user_id])

      # 未読の通知を既読にする
      current_user.passive_notifications.where(checked: false).update_all(checked: true)
      notifications = current_user.passive_notifications.where.not(visitor_id: current_user.id)

      # 通知の配列を直接使用して、フォローといいねのユーザーを生成
      follow_visitors = []
      like_visitors = []
      notifications.each do |notification|
        if notification.action == "follow"
          follow_visitors.push(notification.visitor)
        elsif notification.action == "like" && notification.visitor_id != current_user.id
          like_visitors.push(notification.visitor)
        end
      end

      render json: {
        follow_visitors: ActiveModel::Serializer::CollectionSerializer.new(follow_visitors, each_serializer: UserSerializer),
        like_visitors: ActiveModel::Serializer::CollectionSerializer.new(like_visitors, each_serializer: UserSerializer),
        notifications: ActiveModel::Serializer::CollectionSerializer.new(notifications, each_serializer: NotificationSerializer),
      }, status: 200
    end
  end
end