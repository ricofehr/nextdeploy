# This class format vm_techno type properties for json output
#
# @author Eric Fehr (ricofehr@nextdeploy.io, github: ricofehr)
class SuperviseSerializer < ActiveModel::Serializer
  attributes :id, :status

  has_many :techno, key: :techno
  has_many :vm, key: :vm
end
