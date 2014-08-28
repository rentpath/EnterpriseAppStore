class ProjectsController < ApplicationController
  before_action :project, only: [:show, :edit, :update, :destroy]
  before_action :all_projects, only: [:index, :new, :edit]

  def new
    @project = Project.new
  end

  def edit
    @project.add_error('version', params[:errors]) if params[:errors]
  end

  def create
    @project = Project.new(project_params)
    respond_to do |format|
      if @project.save
        format.html { redirect_to @project, notice: 'Project was successfully created.' }
        format.mobile { redirect_to @project, notice: 'Project was successfully created.' }
        format.json { render action: 'show', status: :created, location: @project }
      else
        format.html { render action: 'new' }
        format.mobile { render action: 'new' }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @project.update(project_params)
        format.html { redirect_to @project, notice: 'Project was successfully updated.' }
        format.mobile { redirect_to @project, notice: 'Project was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.mobile { render action: 'edit' }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @project.destroy
    respond_to do |format|
      format.html { redirect_to projects_url }
      format.mobile { redirect_to projects_url }
      format.json { head :no_content }
    end
  end

  private
  def all_projects
    @projects ||= Project.all.sort_by(&:name)
  end

  def project
    @project ||= Project.find(params[:id])
  end

  def project_params
    params[:project]
  end

end