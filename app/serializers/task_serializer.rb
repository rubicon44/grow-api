class TaskSerializer < ActiveModel::Serializer
  attributes :id, :user_id, :content, :end_date, :start_date, :status, :title

  def initialize(object, options={})
  super
    @user = options[:user]
  end

  def attributes(*args)
    hash = super
    if @user
      hash[:user] = UserSerializer.new(object.user).as_json
    end
    hash
  end
end