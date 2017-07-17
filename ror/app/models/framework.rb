# Every project has a framework object
#
# @author Eric Fehr (ricofehr@nextdeploy.io, github: ricofehr)
class Framework < ActiveRecord::Base
  has_many :endpoints, dependent: :destroy
  has_many :uris, dependent: :destroy

  # Name is mandatory
  validates :name, presence: true
end
