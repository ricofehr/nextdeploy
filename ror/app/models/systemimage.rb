# A systemimage stores properties about an exploitation system
#
# @author Eric Fehr (ricofehr@nextdeploy.io, github: ricofehr)
class Systemimage < ActiveRecord::Base
  belongs_to :systemimagetype
  # Each vms is running onto an unique exploitation system
  has_many :vms, dependent: :destroy

  # multiple itmes can be associated with each project
  has_many :project_systemimage, dependent: :destroy
  has_many :projects, through: :project_systemimage

  # some properties are mandatory and must be well-formed
  validates :name, :systemimagetype_id, :glance_id, presence: true
end
