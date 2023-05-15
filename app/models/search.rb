class Search < ApplicationRecord
  def self.search(model, contents, method)
    if model == 'user'
      if method == 'perfect'
        users = User.where(username: contents)
        return { users: users }
      else
        users = User.where('username LIKE ?', '%'+contents+'%')
        return { users: users }
      end
    elsif model == 'task'
      if method == 'perfect'
        tasks = Task.where('title LIKE ?', contents).or(Task.where('content LIKE ?', contents))
        return { tasks: tasks }
      else
        tasks = Task.where('title LIKE ?', '%'+contents+'%')
        return { tasks: tasks }
      end
    end
  end
end