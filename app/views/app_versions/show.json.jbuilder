json.set! :url, (@app_version.url_plist || @app_version.app_artifact.url)
json.set! :version, @app_version.version
