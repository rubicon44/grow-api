# frozen_string_literal: true

class LikeSerializer < ActiveModel::Serializer
  attributes :id, :liked_user_id, :task_id

  def liked_user_id
    object.user_id
  end
end
