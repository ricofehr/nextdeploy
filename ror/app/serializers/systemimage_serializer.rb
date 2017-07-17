# This class format systemimage properties for json output
#
# @author Eric Fehr (ricofehr@nextdeploy.io, github: ricofehr)
class SystemimageSerializer < ActiveModel::Serializer
  attributes :id, :name, :glance_id, :enabled
  delegate :current_user, to: :scope

  has_one :systemimagetype, key: :systemimagetype
  has_many :vms, key: :vms
  has_many :projects, key: :projects

  # HACK return systemimagetype id (no embed option in AMS 0.10)
  #
  # @return [Number]
  def systemimagetype
    object.systemimagetype.id
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
end
