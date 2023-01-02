class Search < ApplicationRecord
  def self.search(model, contents, method)
    if model == 'user'
      if method == 'perfect'
        @users = User.where(username: contents)
        return { users: @users }
      else
        @users = User.where('username LIKE ?', '%'+contents+'%')
        return { users: @users }
      end
    elsif model == 'task'
      if method == 'perfect'
        Task.where(title: contents)
        Task.where(content: contents)
      else
        @tasks = Task.where('title LIKE ?', '%'+contents+'%')
        @task_users = []
        @tasks.each do |task|
          @task_user = User.find(task.user_id)
          @task_users.push(@task_user)
        end
        return { tasks: @tasks, task_users: @task_users }
      end
    end
  end
end