# This class format techno properties for json output
#
# @author Eric Fehr (ricofehr@nextdeploy.io, github: ricofehr)
class TechnoSerializer < ActiveModel::Serializer
  attributes :id, :name, :dockercompose, :playbook
  delegate :current_user, to: :scope

  has_one :technotype, key: :technotype
  has_many :projects, key: :projects
  has_many :vms, key: :vms
  has_many :supervises, key: :supervises

  # HACK return technotype id (no embed option in AMS 0.10)
  #
  # @return [Number]
  def technotype
    object.technotype.id
  end

  # Filter project records for current user
  # HACK return ids list (no embed option in AMS 0.10)
  #
  # @return [Array<Number>]
  def projects
    projects = object.projects
    unless current_user.admin?
      projects = object.projects.select { |project| project.users.include?(current_user) }
    end
    projects.map { |p| p.id }
  end

  # Filter vm records for current user
  # HACK return ids list (no embed option in AMS 0.10)
  #
  # @return [Array<Number>]
  def vms
    vms = []
    if current_user.admin?
      vms = object.vms
    elsif current_user.lead?
      vms = object.vms.select { |vm| vm.project.users.include?(current_user) }
    elsif current_user.dev?
      vms = object.vms.select { |vm| vm.user.id == current_user.id || vm.is_jenkins }
    else
      vms = object.vms.select { |vm| vm.user.id == current_user.id }
    end
    vms.map { |v| v.id }
  end

  # Filter supervise records for current user
  # HACK return ids list (no embed option in AMS 0.10)
  #
  # @return [Array<Number>]
  def supervises
    supervises = []
    if current_user.admin?
      supervises = object.supervises
    elsif current_user.lead?
      supervises = object.supervises.select { |superv| superv.vm.project.users.include?(current_user) }
    elsif current_user.dev?
      supervises = object.supervises.select { |superv| superv.vm.user.id == current_user.id || superv.vm.is_jenkins }
    else
      supervises = object.supervises.select { |superv| superv.vm.user.id == current_user.id }
    end
    supervises.map { |s| s.id }
  end
end
