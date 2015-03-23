# Just a Joint class between Project and Vmsize objects
#
# @author Eric Fehr (eric.fehr@publicis-modem.fr, github: ricofehr)
class ProjectVmsize < ActiveRecord::Base
  belongs_to :project
  belongs_to :vmsize
end
