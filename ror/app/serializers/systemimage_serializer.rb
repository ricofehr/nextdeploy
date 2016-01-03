# This class format systemimage properties for json output
#
# @author Eric Fehr (ricofehr@nextdeploy.io, github: ricofehr)
class SystemimageSerializer < ActiveModel::Serializer
  attributes :id, :name, :glance_id, :enabled
  delegate :current_user, to: :scope

  has_one :systemimagetype, key: :systemimagetype
  has_many :vms, key: :vms

  # dont display vms if user is not allowed for
  def vms
    if current_user.admin?
      object.vms
    elsif current_user.lead?
      object.vms.select { |vm| !vm.user.admin? && vm.project.users.include?(current_user) }
    else
      object.vms.select { |vm| vm.user.id == current_user.id }
    end
  end
end
