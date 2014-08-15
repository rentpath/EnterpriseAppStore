class ProjectsController < ApplicationController
  before_action :set_project, only: [:show, :edit, :update, :destroy]
  before_action :all_projects, only: [:index, :new, :edit]

  def new
    @project = Project.new
  end

  def edit
    @project.add_error('version', params[:errors]) if params[:errors]
  end

  def create
    process_linked_projects
    @project = Project.new(project_params)
    respond_to do |format|
      if @project.save
        build_linked_projects
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
    process_linked_projects
    build_linked_projects
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
    @projects = Project.all
  end

  def set_project
    @project = Project.find(params[:id])
  end

  def project_params
    params[:project]
  end

  def process_linked_projects
    @links = params[:project].delete(:linked_projects)
  end

  def build_linked_projects
    LinkedProject.where("project_id = ? or linked_project_id = ?", params[:id], params[:id]).destroy_all
    if @links
      @links.map do |p|
        LinkedProject.create!(project_id: @project.id.to_i, linked_project_id: p.to_i)
        LinkedProject.create!(project_id: p.to_i, linked_project_id: @project.id.to_i)
      end
    end
  end
end