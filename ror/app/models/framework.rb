# Every project has a framework object
#
# @author Eric Fehr (eric.fehr@publicis-modem.fr, github: ricofehr)
class Framework < ActiveRecord::Base
  has_many :projects, dependent: :destroy

  # Name is mandatory
  validates :name, presence: true
end
