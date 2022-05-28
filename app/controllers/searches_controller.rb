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
        User.where(name: contents)
      else
        User.where('name LIKE ?', '%'+contents+'%')
      end
    elsif model == 'task'
      if method == 'perfect'
        Task.where(title: contents)
        Task.where(content: contents)
      else
        Task.where('title LIKE ?', '%'+contents+'%')
        Task.where('content LIKE ?', '%'+contents+'%')
      end
    end
  end
end