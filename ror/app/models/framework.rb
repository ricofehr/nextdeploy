# Every project has a framework object
#
# @author Eric Fehr (ricofehr@nextdeploy.io, github: ricofehr)
class Framework < ActiveRecord::Base
  has_many :endpoints, dependent: :destroy
  has_many :uris, dependent: :destroy
  #has_many :projects, through: :endpoints, inverse_of: :frameworks

  # Name is mandatory
  validates :name, presence: true
end
