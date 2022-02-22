class UsersController < ApplicationController
  skip_before_action :check_authenticate!, only: %i(create), raise: false

  def index
    @user = User.all
    render json: @user
  end

  def create
    @user = User.new(params_user_create)
    if @user.save
      render json: { user: @user }, status: 201
    else
      render json: {"error": @user.errors}, status: 500
    end
  end

  def show
  end

  def update
  end

  private

  def params_user_create
    params.require(:user).permit(:name, :email)
  end
end
