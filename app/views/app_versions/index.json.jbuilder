json.array!(@app_versions) do |app_version|
  json.extract! app_version, 
  json.url app_version_url(app_version, format: :json)
end
