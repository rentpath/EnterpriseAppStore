class AppVersion < ActiveRecord::Base
  attr_accessible :name, :version, :url_ipa, :url_plist, :url_icon, :notes
end
