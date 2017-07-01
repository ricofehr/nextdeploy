# This class format techno properties for json output
#
# @author Eric Fehr (ricofehr@nextdeploy.io, github: ricofehr)
class TechnoSerializer < ActiveModel::Serializer
  attributes :id, :name, :dockercompose, :playbook
  delegate :current_user, to: :scope

  has_one :technotype, key: :technotype
  has_many :projects, key: :projects
  has_many :supervises, key: :supervises
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
      object.vms.select { |vm| vm.project.users.include?(current_user) }
    else
      object.vms.select { |vm| vm.user.id == current_user.id }
    end
  end

  # dont display vms if user is not allowed for
  def supervises
    if current_user.admin?
      object.supervises
    elsif current_user.lead?
      object.supervises.select { |superv| superv.vm.project.users.include?(current_user) }
    else
      object.supervises.select { |superv| superv.vm.user.id == current_user.id }
    end
  end
end
