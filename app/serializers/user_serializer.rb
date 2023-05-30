# frozen_string_literal: true

class UserSerializer < ActiveModel::Serializer
  attributes :id, :bio, :email, :nickname, :username, :firebase_id

  def initialize(object, options = {})
    super
    @firebase_id = options[:firebase_id]
  end

  def attributes(*args)
    hash = super
    hash.delete(:firebase_id) unless @firebase_id
    hash
  end
end
