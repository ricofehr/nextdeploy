# Its a property for the vms sizing (tiny: 1 vcpus / 512Mo ram, large: 2 vcpus / 4Go ram, ...)
#
# @author Eric Fehr (ricofehr@nextdeploy.io, github: ricofehr)
class Vmsize < ActiveRecord::Base
  # multiple different flavors are possible for a project
  has_many :project_vmsize, dependent: :destroy
  has_many :projects, through: :project_vmsize

  # each vm has one flavvor
  has_many :vms, dependent: :destroy

  # name is mandatory
  validates :title, presence: true
end
