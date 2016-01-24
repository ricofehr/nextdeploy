class Hpmessage < ActiveRecord::Base
  scope :all_relevant, ->(access_level) { where("(expiration > ? OR expiration = 0) AND access_level_min <= ? AND access_level_max >= ?", Time.zone.now, access_level, access_level).order("ordering desc, id") }
end