# Just a Joint class between Vm and Techno objects
#
# @author Eric Fehr (ricofehr@nextdeploy.io, github: ricofehr)
class Supervise < ActiveRecord::Base
  self.table_name = "vm_technos"

  belongs_to :vm
  belongs_to :techno

  # Change current status of the probe
  #
  # @param new_status [Boolean]
  # @return [Boolean] 1 if status has changed his value
  def change_status(new_status)
    if status != new_status
      self.status = new_status
      save
      1
    else
      0
    end
  end
end
