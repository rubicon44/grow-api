class SearchesController < ApplicationController
  def index
    @contents = params[:contents]
    @model = params[:model]
    @method = params[:method]
    @results = search_for(@model, @contents, @method)

    render json: { results: @results }
  end

  private
  def search_for(model, contents, method)
    if model == 'user'
      if method == 'perfect'
        @users = User.where(username: contents)
        return { "users_for_user" => @users }
      else
        @users = User.where('username LIKE ?', '%'+contents+'%')
        return { "users_for_user" => @users }
      end
    elsif model == 'task'
      if method == 'perfect'
        Task.where(title: contents)
        Task.where(content: contents)
      else
        @tasks = Task.where('title LIKE ?', '%'+contents+'%')
        # @tasks = Task.where('content LIKE ?', '%'+contents+'%')

        @users = []
        @tasks.each do |task|
          @user = User.find(task.user_id)
          @users.push(@user)
        end
        return { "tasks" => @tasks, "users" => @users }
      end
    end
  end
end