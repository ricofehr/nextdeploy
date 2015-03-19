# Just a Joint class between Project and Flavor objects
#
# @author Eric Fehr (eric.fehr@publicis-modem.fr, github: ricofehr)
class ProjectFlavor < ActiveRecord::Base
  belongs_to :project
  belongs_to :flavor
end
