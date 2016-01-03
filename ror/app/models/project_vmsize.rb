# Just a Joint class between Project and Vmsize objects
#
# @author Eric Fehr (ricofehr@nextdeploy.io, github: ricofehr)
class ProjectVmsize < ActiveRecord::Base
  belongs_to :project
  belongs_to :vmsize
end
