# This class format vmsize properties for json output
#
# @author Eric Fehr (ricofehr@nextdeploy.io, github: ricofehr)
class VmsizeSerializer < ActiveModel::Serializer
  attributes :id, :title, :description
  delegate :current_user, to: :scope

  has_many :projects, key: :projects
  has_many :vms, key: :vms

  # dont display projects if user is not allowed for
  def projects
    if current_user.admin?
      object.projects
    else
      object.projects.select { |project| project.users.include?(current_user) }
    end
  end

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
