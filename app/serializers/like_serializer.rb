# frozen_string_literal: true

class LikeSerializer < ActiveModel::Serializer
  attributes :id, :liked_user_id, :task_id

  def liked_user_id
    object.user_id
  end

  def self.serialize_likes_collection(collection, options = {})
    ActiveModel::Serializer::CollectionSerializer.new(collection, each_serializer: LikeSerializer, **options).as_json
  end
end
