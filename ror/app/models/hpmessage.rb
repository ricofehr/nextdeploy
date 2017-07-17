# Stores information post for the homepage Wall
#
# @author Eric Fehr (ricofehr@nextdeploy.io, github: ricofehr)
class Hpmessage < ActiveRecord::Base
  # Get all valid records
  scope :all_relevant,
        ->(access_level) do
          where(
            '(expiration > :expiration OR expiration = 0) AND ' +
            'access_level_min <= :access_level AND ' +
            'access_level_max >= :access_level',
            expiration: Time.zone.now,
            access_level: access_level
          ).order("ordering desc, id")
        end
end
