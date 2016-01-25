# Store all exploitation system whi are the same type: unix / linux / windows mainly
#
# @author Eric Fehr (ricofehr@nextdeploy.io, github: ricofehr)
class Systemimagetype < ActiveRecord::Base
  # One exploitation system is caracterised by one unique property type
  has_many :systemimages, dependent: :destroy

  # some properties are mandatory and must be well-formed
  validates :name, presence: true
end
