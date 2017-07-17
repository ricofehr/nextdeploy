# This class format systemimage properties for json output
#
# @author Eric Fehr (ricofehr@nextdeploy.io, github: ricofehr)
class SystemimageSerializer < ActiveModel::Serializer
  attributes :id, :name, :glance_id, :enabled
  delegate :current_user, to: :scope

  has_one :systemimagetype, key: :systemimagetype
  has_many :vms, key: :vms
  has_many :projects, key: :projects

  # Filter project records for current user
  #
  # @return [Array<Project>]
  def projects
    if current_user.admin?
      object.projects
    else
      object.projects.select { |project| project.users.include?(current_user) }
    end
  end

  # Filter vm records for current user
  #
  # @return [Array<Vm>]
  def vms
    if current_user.admin?
      object.vms
    elsif current_user.lead?
      object.vms.select { |vm| vm.project.users.include?(current_user) }
    elsif current_user.dev?
      object.vms.select { |vm| vm.user.id == current_user.id || vm.is_jenkins }
    else
      object.vms.select { |vm| vm.user.id == current_user.id }
    end
  end
end
