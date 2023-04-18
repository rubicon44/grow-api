class UserSerializer < ActiveModel::Serializer
  attributes :id, :firebase_id, :bio, :email, :nickname, :username
end