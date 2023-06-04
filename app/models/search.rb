# frozen_string_literal: true

class Search < ApplicationRecord
  def self.search(model, contents, method)
    case model
    when 'user'
      Search.search_users(contents, method)
    when 'task'
      Search.search_tasks(contents, method)
    else
      { errors: 'Invalid search model' }
    end
  end

  def self.search_users(contents, method)
    users = if method == 'perfect'
              User.where('username = ? OR nickname = ?', contents, contents)
            else
              User.where('username LIKE ? OR nickname LIKE ?', "%#{contents}%", "%#{contents}%")
            end
    { users: users }
  end

  def self.search_tasks(contents, method)
    tasks = if method == 'perfect'
              Task.where('title = ? OR content = ?', contents, contents)
            else
              Task.where('title LIKE ? OR content LIKE ?', "%#{contents}%", "%#{contents}%")
            end
    { tasks: tasks }
  end
end
