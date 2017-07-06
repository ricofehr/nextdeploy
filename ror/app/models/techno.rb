# Stores details about one system technology (apache / mongo / mysql / nodejs / ...)
#
# @author Eric Fehr (ricofehr@nextdeploy.io, github: ricofehr)
class Techno < ActiveRecord::Base
  belongs_to :technotype
  # Technos are associated with project object
  has_many :project_technos, dependent: :destroy
  has_many :projects, through: :project_technos
  # Technos are associated with vm object
  has_many :supervises, dependent: :destroy
  has_many :vms, through: :supervises

  # some properties are mandatory and must be well-formed
  validates :name, :puppetclass, presence: true
end
