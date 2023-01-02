class SearchesController < ApplicationController
  def index
    @contents = params[:contents]
    @model = params[:model]
    @method = params[:method]
    @results = Search.search(@model, @contents, @method)

    render json: { results: @results }
  end
end