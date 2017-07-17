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

  # Filter supervise records for current user
  #
  # @return [Array<Supervise>]
  def supervises
    if current_user.admin?
      object.supervises
    elsif current_user.lead?
      object.supervises.select { |superv| superv.vm.project.users.include?(current_user) }
    elsif current_user.dev?
      object.supervises.select { |superv| superv.vm.user.id == current_user.id || superv.vm.is_jenkins }
    else
      object.supervises.select { |superv| superv.vm.user.id == current_user.id }
    end
  end
end
