# frozen_string_literal: true

class Search < ApplicationRecord
  def self.search(model, contents, method)
    if model == 'user'
      users = if method == 'perfect'
                User.where(username: contents)
              else
                User.where('username LIKE ?', "%#{contents}%")
              end
      { users: users }
    elsif model == 'task'
      tasks = if method == 'perfect'
                Task.where('title LIKE ?', contents).or(Task.where('content LIKE ?', contents))
              else
                Task.where('title LIKE ?', "%#{contents}%")
              end
      { tasks: tasks }
    end
  end
end
