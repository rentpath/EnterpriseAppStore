class AppVersionsController < ApplicationController
  before_action :set_app_version, only: [:show, :edit, :update, :destroy, :install]
  before_action :find_project, only: [:index, :new, :create, :edit, :show]
  skip_before_filter :verify_authenticity_token

  # GET /app_versions
  # GET /app_versions.json
  def index
    @app_versions = @project.app_versions
    @android_versions = Array.new
    @ios_versions     = Array.new

    @app_versions.each do |app_version|
      if app_version.app_artifact.url.rindex('.ipa')
        @ios_versions << app_version
      else
        @android_versions << app_version
      end
    end

    asc_sort = ->(a, b) {

      #if a < b then return -1
      #if a = b then return  0
      #if a > b then return  1

      a_version = a.version.sub('-QA_ENTERPRISE', '')
      b_version = b.version.sub('-QA_ENTERPRISE', '')

      return 0 if a_version.equal?(b_version)

      a_array = a_version.split('.')
      b_array = b_version.split('.')

      if a_array.size == b_array.size || a_array.size < b_array.size
        for i in 0..a_array.size
          next if a_array[i].to_i == b_array[i].to_i
          return -1 if a_array[i].to_i < b_array[i].to_i
          return 1 if a_array[i].to_i > b_array[i].to_i
        end
      elsif a_array.size > b_array.size
        for i in 0..b_array.size
          next if a_array[i].to_i == b_array[i].to_i
          return -1 if a_array[i].to_i < b_array[i].to_i
          return 1 if a_array[i].to_i > b_array[i].to_i
        end
      end

      a_version <=> b_version
    }

    @android_versions = @android_versions.sort(&asc_sort)
    @ios_versions = @ios_versions.sort(&asc_sort)

    puts @ios_versions
  end

  # GET /app_versions/1
  # GET /app_versions/1.json
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
    apk_url = @app_version.app_artifact.url
    project = Project.find(@app_version.project_id)
    filename = "#{project.title}-#{@app_version.version}.apk"
    data = open(apk_url)
    temp_file = File.open data
    headers['Content-Type'] = 'application/vnd.android.package-archive'
    send_file temp_file, :type => 'application/vnd.android.package-archive',
                         :disposition => 'attachment',
                         :filename => filename
  end

  # GET /app_versions/new
  def new
    @app_version = @project.app_versions.new
  end

  # GET /app_versions/1/edit
  def edit
    @app_version = @project.app_versions.find(params[:id])
  end

  # POST /app_versions
  # POST /app_versions.json
  def create
    @app_version = @project.app_versions.create(app_version_params)

    respond_to do |format|
      if @app_version.save

        artifact_url = @app_version.app_artifact.url
        if artifact_url.rindex('.ipa')
          # iOS build

          # Get the plist root folder
          plist_root = "#{Rails.root}/public/plist"

          # Get the projects specific plist template and parse
          plist_template = "#{plist_root}/template.plist"
          plist = Plist::parse_xml(plist_template)

          puts "Template Plist: #{plist}"

          # Update ipa URL, Bundle ID, Bundle Version
          plist['items'][0]['assets'][0]['url'] = artifact_url
          plist['items'][0]['metadata']['bundle-identifier'] = @project.bundle_identifier
          plist['items'][0]['metadata']['bundle-version'] = @app_version.version
          plist['items'][0]['metadata']['title'] = @project.title

          # Create the final path for the new plist
          project_name = @project.name.gsub(/\s+/, "-")
          project_path = "#{plist_root}/#{project_name}"
          new_plist_path = "#{project_path}/#{project_name}-#{@app_version.version}.plist"
          Dir.mkdir project_path if !Dir.exists? project_path

          puts "About to save plist to: #{new_plist_path}"

          # Finally, save the new plist
          save_plist(plist, new_plist_path)

          # Assign the new plist to the app_plist attribute so it will be uploaded to S3
          @app_version.app_plist = File.open(new_plist_path)

          if @app_version.save

            @app_version.url_plist = "itms-services://?action=download-manifest&amp;url=#{@app_version.app_plist.url}"

            if @app_version.save

              NotificationMailer.send_notification(@project).deliver

              format.html { redirect_to "/projects/#{@app_version.project_id}/app_versions/#{@app_version.id}", notice: 'App version was successfully created.' }
              format.json { render action: 'show', status: :created, location: { :saved => true } }
            else
              format.html { render action: 'new' }
              format.json { render json: @app_version.errors, status: :unprocessable_entity }
            end
          else
            format.html { render action: 'new' }
            format.json { render json: @app_version.errors, status: :unprocessable_entity }
          end

        else
          # Android Build

          NotificationMailer.send_notification(@project).deliver

          format.html { redirect_to "/projects/#{@app_version.project_id}/app_versions/#{@app_version.id}", notice: 'App version was successfully created.' }
          format.json { render action: 'show', status: :created, location: { :saved => true } }

        end
      else
        format.html { render action: 'new' }
        format.json { render json: @app_version.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /app_versions/1
  # PATCH/PUT /app_versions/1.json
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

  # DELETE /app_versions/1
  # DELETE /app_versions/1.json
  def destroy
    @app_version.destroy
    respond_to do |format|
      format.html { redirect_to "/projects/#{@app_version.project_id}/app_versions/", notice: 'App version was successfully deleted.' }
      format.mobile { redirect_to "/projects/#{@app_version.project_id}/app_versions/", notice: 'App version was successfully deleted.' }
      format.json { head :no_content }
    end
  end

  def latest_version
    project = Project.find(params[:id])
    app_version = project.app_versions.last
    latest_version = app_version.version
    render :json => { :version => latest_version }
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_app_version
      @app_version = AppVersion.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def app_version_params
      params[:app_version]
    end

    def find_project
      @project = Project.find(params[:project_id])
    end

    def save_plist(obj, path)
      File.open(path, 'w+') do |f|
        return_value = f.write(obj.to_plist)
        puts "Return Value: #{return_value}"
      end
    end

end
