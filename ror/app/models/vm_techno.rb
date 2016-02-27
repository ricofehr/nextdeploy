# Just a Joint class between Vm and Techno objects
#
# @author Eric Fehr (ricofehr@nextdeploy.io, github: ricofehr)
class VmTechno < ActiveRecord::Base
  belongs_to :vm
  belongs_to :techno
end
