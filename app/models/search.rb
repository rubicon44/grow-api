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

  # TODO: User検索で「username」「nickname」どちらでも検索できるようにする。
  def self.search_users(contents, method)
    users = if method == 'perfect'
              User.where(username: contents)
            else
              User.where('username LIKE ?', "%#{contents}%")
            end
    { users: users }
  end

  def self.search_tasks(contents, method)
    tasks = if method == 'perfect'
              Task.where('title LIKE ?', contents).or(Task.where('content LIKE ?', contents))
            else
              Task.where('title LIKE ?', "%#{contents}%")
            end
    { tasks: tasks }
  end
end
