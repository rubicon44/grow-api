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
    users = (User.where('username LIKE ? OR nickname LIKE ?', "%#{contents}%", "%#{contents}%") if method == 'partial')
    { users: users }
  end

  def self.search_tasks(contents, method)
    tasks = (Task.where('title LIKE ? OR content LIKE ?', "%#{contents}%", "%#{contents}%") if method == 'partial')
    { tasks: tasks }
  end
end
