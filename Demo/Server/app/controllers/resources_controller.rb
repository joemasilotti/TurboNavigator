class ResourcesController < ApplicationController
  def index
    @resources = Resource.order(:created_at)
  end

  def show
    @resource = Resource.find(params[:id])
  end

  def new
    @resource = Resource.new
  end

  def edit
    @resource = Resource.find(params[:id])
  end

  def create
    @resource = Resource.new(resource_params)
    if @resource.save
      flash.notice = "Resource was successfully created."
      refresh_or_redirect_to @resource
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    @resource = Resource.find(params[:id])
    if @resource.update(resource_params)
      flash.notice = "Resource was successfully updated."
      refresh_or_redirect_to @resource
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    Resource.find(params[:id]).destroy
    flash.notice = "Resource was successfully deleted."
    refresh_or_redirect_to resources_path
  end

  private

  def resource_params
    params.require(:resource).permit(:title, :description)
  end
end
