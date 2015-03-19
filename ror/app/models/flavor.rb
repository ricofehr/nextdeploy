# a Flavor is a property for the vms sizing (tiny: 1 vcpus / 512Mo ram, large: 2 vcpus / 4Go ram, ...)
#
# @author Eric Fehr (eric.fehr@publicis-modem.fr, github: ricofehr)
class Flavor < ActiveRecord::Base
  # multiple different flavors are possible for a project
  has_many :project_flavor, dependent: :destroy
  has_many :projects, through: :project_flavor

  # each vm has one flavvor
  has_many :vms, dependent: :destroy

  # name is mandatory
  validates :title, presence: true
end
