# Store all exploitation system whi are the same type: unix / linux / windows mainly
#
# @author Eric Fehr (eric.fehr@publicis-modem.fr, github: ricofehr)
class Systemimagetype < ActiveRecord::Base
  # One exploitation system is caracterised by one unique property type
  has_many :systemimages, dependent: :destroy

  # A project can be run into some differents operating system but this ones must be into the same type
  has_many :projects, dependent: :destroy

  # some properties are mandatory and must be well-formed
  validates :name, presence: true
end
