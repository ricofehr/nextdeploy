# Just a Joint class between Vm and Techno objects
#
# @author Eric Fehr (ricofehr@nextdeploy.io, github: ricofehr)
class Supervise < ActiveRecord::Base
  self.table_name = "vm_technos"

  belongs_to :vm
  belongs_to :techno

  scope :find_by_foreigns, ->(vm_id, techno_id){ where("vm_id=#{vm_id} AND techno_id=#{techno_id}") }

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
