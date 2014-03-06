module AppVersionsHelper
  include Plist

  def build_plist(project, app_version, artifact_url)
    # Get the plist root folder
    plist_root = "#{Rails.root}/public/plist"

    # Get the projects specific plist template and parse
    plist_template = "#{plist_root}/template.plist"
    plist = Plist::parse_xml(plist_template)

    # Update ipa URL, Bundle ID, Bundle Version
    plist['items'][0]['assets'][0]['url'] = artifact_url
    plist['items'][0]['metadata']['bundle-identifier'] = project.bundle_identifier
    plist['items'][0]['metadata']['bundle-version'] = app_version.version
    plist['items'][0]['metadata']['title'] = project.title

    # Create the final path for the new plist
    project_name = project.name.gsub(/\s+/, "-")
    project_path = "#{plist_root}/#{project_name}"
    new_plist_path = "#{project_path}/#{project_name}-#{app_version.version}.plist"
    Dir.mkdir project_path if !Dir.exists? project_path

    # Finally, save the new plist
    save_plist(plist, new_plist_path)

    new_plist_path
  end

  def sort_desc(desc)
    ->(a, b) {

      #if a < b then return  1
      #if a = b then return  0
      #if a > b then return -1

      sort_plus  = (desc) ? 1 : -1
      sort_minus = (desc) ? -1 : 1

      a_version = a.version.sub(/-\w*/, '')
      b_version = b.version.sub(/-\w*/, '')

      return 0 if a_version.equal?(b_version)

      a_array = a_version.split('.')
      b_array = b_version.split('.')

      if a_array.size == b_array.size || a_array.size < b_array.size
        for i in 0..a_array.size
          next if a_array[i].to_i == b_array[i].to_i
          return sort_plus if a_array[i].to_i < b_array[i].to_i
          return sort_minus if a_array[i].to_i > b_array[i].to_i
        end
      elsif a_array.size > b_array.size
        for i in 0..b_array.size
          next if a_array[i].to_i == b_array[i].to_i
          return sort_plus if a_array[i].to_i < b_array[i].to_i
          return sort_minus if a_array[i].to_i > b_array[i].to_i
        end
      end

      a_version <=> b_version
    }
  end

  def notify_users(project)
    User.where.each do |user|
      NotificationMailer.send_notification(user, project).deliver
    end
  end

  def save_plist(obj, path)
    File.open(path, 'w+') do |f|
      f.write(obj.to_plist)
    end
  end

  def remove_old_builds_for_project(project)
    all_versions = project.app_versions
    ios_versions = Array.new
    android_versions = Array.new
    all_versions.each do |app_version|
      if is_ios(app_version)
        ios_versions << app_version
      else
        android_versions << app_version
      end
    end

    oldest_ios_version = determine_oldest_id_to_keep(ios_versions)
    oldest_android_version = determine_oldest_id_to_keep(android_versions)

    latest_is_ios = is_ios(all_versions.last)
    all_versions.each do |version|
      if latest_is_ios
        version.destroy if is_ios(version) && version.id < oldest_ios_version && ios_versions.count >= 10
      else
        version.destroy if is_android(version) && version.id < oldest_android_version && android_versions.count >= 10
      end
    end
  end

  def determine_oldest_id_to_keep(versions)
    oldest_id = 0
    ids = []
    versions.each do |version|
      ids << version.id
    end
    current_index = 0
    ids = ids.sort {|x,y| y <=> x}
    ids.each do |id|
      oldest_id = id
      current_index = current_index + 1
      return oldest_id if current_index >= 10
    end
    oldest_id
  end

  def is_ios(version)
    (version.app_artifact.url.rindex('.ipa')) ? true : false
  end

  def is_android(version)
    (version.app_artifact.url.rindex('.apk')) ? true : false
  end

end
