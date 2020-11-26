class TasksController < ApplicationController
  def index
    @task = Task.all
    render json: @task
  end

  def show
    @task = Task.find(params[:id])
    render json: @task
  end

  def create
    @task = Task.create(task: params[:task])

    if @man.save
      render json: @task, status: 201
    else
      render json: @task.errors, status: 500
    end
  end

  def update
    @task = Task.find(params[:id])
    @task.update_attributes(task: params[:task])
    render json: @task
  end

  def destroy
    @task = Task.find(params[:id])
    if @task.destroy
      head :no_content, status: :ok
    else
      render json: @task.errors, status: :unprocessable_entity
    end
  end
end
