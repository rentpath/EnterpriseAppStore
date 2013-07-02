class CreateAppVersions < ActiveRecord::Migration
  def change
    create_table :app_versions do |t|
      t.string :name
      t.string :version
      t.string :url_ipa
      t.string :url_icon
      t.string :url_plist
      t.text :notes

      t.timestamps
    end
  end
end
