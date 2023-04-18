class LikeSerializer < ActiveModel::Serializer
  attributes :like_id, :liked_user_id, :task_id

  def like_id
    object.id
  end

  def liked_user_id
    object.user_id
  end
end