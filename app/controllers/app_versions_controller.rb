class AppVersionsController < ApplicationController
  include AppVersionsHelper
  before_action :set_app_version, only: [:show, :edit, :update, :destroy, :install, :plist]
  before_action :project, only: [:index, :new, :create, :edit, :show, :plist]
  skip_before_filter :verify_authenticity_token
  skip_before_filter :authenticate_user!, only: [:plist]

  def index
    @app_versions     = @project.app_versions
    @android_versions = Array.new
    @ios_versions     = Array.new

    @app_versions.each do |app_version|
      if app_version.app_artifact.url.rindex('.ipa')
        @ios_versions << app_version
      else
        @android_versions << app_version
      end
    end

    @android_versions = @android_versions.sort(&sort_desc(true))
    @ios_versions = @ios_versions.sort(&sort_desc(true))
  end

  def show
    @artifact_url = "/install/#{@app_version.id}"
	  @image_url = 'android.png'
    if @app_version.app_artifact.url.rindex('.ipa')
      @artifact_url = @app_version.url_plist
      @image_url = 'apple.png'
    end
  end

  def install
    require 'net/http'
    require 'open-uri'
    apk_url   = @app_version.app_artifact.url
    project   = Project.find(@app_version.project_id)
    filename  = "#{project.title}-#{@app_version.version}.apk"
    data      = open(apk_url)
    temp_file = File.open data
    headers['Content-Type'] = 'application/vnd.android.package-archive'
    send_file temp_file, :type => 'application/vnd.android.package-archive',
                         :disposition => 'attachment',
                         :filename => filename
  end

  def new
    @app_version = @project.app_versions.new
  end

  def edit
    @app_version = @project.app_versions.find(params[:id])
  end

  def create
    respond_to do |format|
      begin
        @app_version = check_app_version_already_stored(app_version_params)
        unless @app_version
          @app_version = @project.app_versions.create!(app_version_params) 
          @app_version.build_plist(project_app_version_plist_url(@project, @app_version))
          remove_old_builds_for_project(@project)
          @app_version.save!
        end
        format.html { redirect_to "/projects/#{@app_version.project_id}/app_versions/#{@app_version.id}", notice: 'App version was successfully created.' }
        format.json { render action: 'show', status: :created, location: { :saved => true } }
      rescue ActiveRecord::RecordInvalid => e
        format.html { redirect_to edit_project_url(@project, {errors: e.message}) }
        format.json { render json: {error: e.message}, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @app_version.update(app_version_params)
        format.html { redirect_to "/projects/#{@app_version.project_id}/app_versions/#{@app_version.id}", notice: 'App version was successfully updated.' }
        format.mobile { redirect_to "/projects/#{@app_version.project_id}/app_versions/#{@app_version.id}", notice: 'App version was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.mobile { render action: 'edit' }
        format.json { render json: @app_version.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @app_version.destroy
    respond_to do |format|
      format.html { redirect_to "/projects/#{@app_version.project_id}/app_versions/", notice: 'App version(s) was successfully deleted.' }
      format.mobile { redirect_to "/projects/#{@app_version.project_id}/app_versions/", notice: 'App version(s) was successfully deleted.' }
      format.json { head :no_content }
    end
  end

  def delete_by_version
    ids = find_by_version.map do |version|
      version.decrement_project_version_if_needed
      version.destroy
      version.id
    end
    render json: {ids: ids}
  end

  def latest_version
    project = Project.find(params[:id])
    app_version = project.app_versions.last
    latest_version = app_version.version
    render :json => { :version => latest_version }
  end

  def plist
    match_timestamp_key ? 
      render({xml: @app_version.plist_content, content_type: 'application/xml'}) : 
      render(json: {result: "auth error"}, status: :unprocessable_entity)
  end

  private

  def set_app_version
    @app_version = AppVersion.find(params[:id] || params[:app_version_id])
  end

  def find_by_version
    return [] unless params[:version]
    AppVersion.where(version: params[:version])
  end

  def app_version_params
    @app_version_params ||= begin
      parse_out_sha
      params[:app_version]
    end
  end

  def project
    begin
      @project ||= Project.find(params[:project_id])
    rescue ActiveRecord::RecordNotFound
      render(json: {error: 'could not find project', status: :unprocessable_entity}) unless @project 
    end
  end

  def parse_out_sha
    return if !params[:app_version] or !params[:app_version][:notes]
    notes = params[:app_version][:notes]
    match = notes.match(/([a-f]+|[0-9]+){40}/)
    params[:app_version][:sha] = match[0] if match
  end

  def match_timestamp_key
    @app_version && @app_version.url_plist && (params.keys.member?(@app_version.url_plist.split('?').last))
  end

  def check_app_version_already_stored(app_version_params)
    return if !app_version_params[:sha] or !app_version_params[:version]
    @project.app_versions.where("sha=? and version=?", app_version_params[:sha], app_version_params[:version]).first
  end

end
