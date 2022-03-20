class User < ApplicationRecord
  # include ActiveModel::Serializers::JSON
  has_many :tasks
end
