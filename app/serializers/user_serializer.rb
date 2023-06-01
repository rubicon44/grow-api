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

  def self.serialize_users_collection(collection, options = {})
    ActiveModel::Serializer::CollectionSerializer.new(collection, each_serializer: UserSerializer, **options).as_json
  end

  def self.serialize_user(user)
    UserSerializer.new(user).as_json
  end
end
