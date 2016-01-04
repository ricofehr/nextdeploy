# This object stores all property about a brand
#
# @author Eric Fehr (ricofehr@nextdeploy.io, github: ricofehr)
class Brand < ActiveRecord::Base
  # Some projects are included with a brand
  has_many :projects, dependent: :destroy

  # name is mandatory
  validates :name, presence: true
end
