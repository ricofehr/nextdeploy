# This class format vm_techno type properties for json output
#
# @author Eric Fehr (ricofehr@nextdeploy.io, github: ricofehr)
class SuperviseSerializer < ActiveModel::Serializer
  attributes :id, :status

  has_many :techno, key: :techno
  has_many :vm, key: :vm

  # HACK return techno id (no embed option in AMS 0.10)
  #
  # @return [Number]
  def techno
    object.techno.id
  end

  # HACK return vm id (no embed option in AMS 0.10)
  #
  # @return [Number]
  def vm
    object.vm.id
  end
end
