class NotificationsController < ApplicationController
  def index
    @current_user = User.find(params[:user_id])
    @notifications = @current_user.passive_notifications
    @notifications.where(checked: false).each do |notification|
      notification.update(checked: true)
    end

    @notification = @notifications.where.not(visitor_id: @current_user.id)

    @follow_visitors = []
    @like_visitors = []
    @notifications.each do |notification|
      if notification.action == "follow"
        @visitor_id = User.find(notification.visitor_id)
        @follow_visitors.push(@visitor_id)
      end

      if notification.action == "like"
        if notification.visitor_id != @current_user.id
          @visitor_id = User.find(notification.visitor_id)
          @like_visitors.push(@visitor_id)
        end
      end
    end

    render json: { notifications: @notifications, current_user: @current_user, follow_visitors: @follow_visitors, like_visitors: @like_visitors }
  end
end
