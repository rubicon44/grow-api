# frozen_string_literal: true

class Search < ApplicationRecord
  def self.search(model, contents, method)
    case model
    when 'task'
      search_tasks(contents, method)
    else
      search_users(contents, method)
    end
  end

  def self.search_tasks(contents, method)
    tasks = Task.where('title LIKE ? OR content LIKE ?', "%#{contents}%", "%#{contents}%") if method == 'partial'
    tasks || []
  end

  def self.search_users(contents, method)
    if method == 'partial'
      users = User.where('username LIKE ? OR nickname LIKE ? OR bio LIKE ?', "%#{contents}%", "%#{contents}%",
                         "%#{contents}%")
    end
    users || []
  end
end
