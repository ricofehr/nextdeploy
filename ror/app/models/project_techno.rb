# Just a Joint class between Project and Techno objects
#
# @author Eric Fehr (ricofehr@nextdeploy.io, github: ricofehr)
class ProjectTechno < ActiveRecord::Base
  belongs_to :project
  belongs_to :techno
end
