class TaskSerializer < ActiveModel::Serializer
  attributes :id, :user_id, :content, :end_date, :start_date, :status, :title
  belongs_to :user, serializer: UserSerializer
  has_many :likes, serializer: LikeSerializer
end