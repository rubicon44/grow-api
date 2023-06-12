# frozen_string_literal: true

class Search < ApplicationRecord
  def self.search(model, contents, method)
    case model
    when 'task'
      search_tasks(contents, method)
    when 'user'
      search_users(contents, method)
    else
      { tasks: [], users: [] }
    end
  end

  def self.search_tasks(contents, method)
    tasks = Task.where('title LIKE ? OR content LIKE ?', "%#{contents}%", "%#{contents}%") if method == 'partial'
    { tasks: tasks || [] }
  end

  def self.search_users(contents, method)
    users = User.where('username LIKE ? OR nickname LIKE ?', "%#{contents}%", "%#{contents}%") if method == 'partial'
    { users: users || [] }
  end
end
