class LikesController < ApplicationController
  skip_before_action :check_authenticate!, only: %i(index, create, destroy), raise: false

  def index
    # todo: フロントに返却するjsonの形はどのようなものがベストか考えよう。
    # フロントの人が使いやすいように、またバックエンドの人も作りやすいように。直感的に作る？何かのルールを参考にする？

    # todo: API側でcountしてから返すのではなく、front側で配列.lengthで長さを取得した方が良いらしい(検証)。

    @like = Like.find_by(user_id: params[:current_user_id], task_id: params[:task_id])
    if @like.present?
      @task_id = @like.task_id
    end

    @like_count = Like.where(task_id: params[:task_id]).count
    @like = Like.find_by(user_id: params[:current_user_id])
    if @like.present?
      @liked_user_id = @like.user_id
      @like_id = @like.id
    end
    render json: { task_id: @task_id, like_count: @like_count, liked_user_id: @liked_user_id, like_id: @like_id }
  end

  def show
  end

  def create
    @task = Task.find(params[:task_id])
    @task_id = @task.id
    @current_user = User.find(params[:current_user_id])
    @current_user.like(@task)

    @like_count = Like.count(params[:task_id])
    @like = Like.find_by(user_id: params[:current_user_id])
    if @like.present?
      @liked_user_id = @like.user_id
      @like_id = @like.id
    end
    render json: { task_id: @task_id, like_count: @like_count, liked_user_id: @liked_user_id, like_id: @like_id }
  end

  def destroy
    @task = Task.find(params[:task_id])
    @current_user = User.find(params[:current_user_id])
    @current_user.unlike(@task)

    @like_count = Like.count(params[:task_id])
    @like = Like.find_by(user_id: params[:current_user_id])
    if @like.present?
      @liked_user_id = @like.user_id
      @like_id = @like.id
    end
    render json: { like_count: @like_count, liked_user_id: @liked_user_id, like_id: @like_id }
  end

  private

  def params_like_create
    params.require(:like).permit(:task_id, :current_user_id)
  end
end
