# frozen_string_literal: true

module V1
  class SearchesController < ApiController
    def index
      contents = params[:contents]
      model = params[:model]
      method = params[:method]
      return render_bad_request('search model') unless valid_model?(model)

      results = Search.search(model, contents, method)
      paginated_results = build_paginated_results(results)

      render json: paginated_results, status: :ok
    end

    private

    def serialize_tasks(tasks)
      TaskSerializer.serialize_tasks_collection(tasks.includes(:user).order('tasks.id DESC'))
    end

    def serialize_users(users)
      UserSerializer.serialize_users_collection(users.includes(:tasks).order('users.id DESC'))
    end

    def valid_model?(model)
      %w[user task].include?(model)
    end

    def build_paginated_results(results)
      page = params[:page].to_i
      page_size = params[:page_size].to_i
      data_type = params[:data_type]

      add_paginated_results(results, page, page_size, data_type)
    end

    def add_paginated_results(results, page, page_size, data_type)
      return add_tasks(results, page, page_size) if data_type == 'tasks'
      return add_users(results, page, page_size) if data_type == 'users'
    end

    def add_tasks(results, page, page_size)
      paginated_results = {}
      if results[:tasks].present?
        paginated_results[:tasks] =
          serialize_tasks(paginate_tasks(results[:tasks], page, page_size))
      end
      paginated_results
    end

    def add_users(results, page, page_size)
      paginated_results = {}
      if results[:users].present?
        paginated_results[:users] =
          serialize_users(paginate_users(results[:users], page, page_size))
      end
      paginated_results
    end

    def paginate_tasks(tasks, page, page_size)
      tasks.limit(page_size).offset((page - 1) * page_size)
    end

    def paginate_users(users, page, page_size)
      users.limit(page_size).offset((page - 1) * page_size)
    end
  end
end
