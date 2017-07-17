# This class format user properties for json output
#
# @author Eric Fehr (ricofehr@nextdeploy.io, github: ricofehr)
class UserSerializer < ActiveModel::Serializer
  attributes :id, :email, :authentication_token, :is_project_create, :is_user_create,
             :is_recv_vms, :company, :quotavm, :quotaprod, :nbpages, :layout, :firstname,
             :lastname, :created_at

  delegate :current_user, to: :scope

  has_one :group, key: :group
  has_many :vms, key: :vms
  has_many :sshkeys, key: :sshkeys
  has_many :projects, key: :projects
  has_many :own_projects, key: :own_projects

  # Give auth_token only for current user
  #
  # @return [String]
  def authentication_token
    object.authentication_token if !current_user || object.id == current_user.id
  end

  # HACK return group id (no embed option in AMS 0.10)
  #
  # @return [Number]
  def group
    object.group.id
  end

  # Filter project records for current user
  # HACK return ids list (no embed option in AMS 0.10)
  #
  # @return [Array<Number>]
  def projects
    projects = object.projects.select { |p| !current_user || p.users.include?(current_user) }
    projects.map { |p| p.id }
  end

  # Filter own_project records for current user
  # HACK return ids list (no embed option in AMS 0.10)
  #
  # @return [Array<Number>]
  def own_projects
    if !current_user || current_user.admin? || object.id == current_user.id
      object.own_projects.map { |o| o.id }
    else
      []
    end
  end

  # Filter vm records for current user
  # HACK return ids list (no embed option in AMS 0.10)
  #
  # @return [Array<Number>]
  def vms
    vms = object.vms.select do |vm|
      !current_user ||
      current_user.id == vm.user.id ||
      current_user.admin? ||
      (current_user.lead? && vm.project.users.include?(current_user)) ||
      (current_user.dev? && vm.project.users.include?(current_user) && vm.is_jenkins)
    end
    vms.map { |v| v.id }
  end

  # Filter sshkey records for current user
  # HACK return ids list (no embed option in AMS 0.10)
  #
  # @return [Array<Number>]
  def sshkeys
    sshkeys = object.sshkeys.select do |sshk|
      !current_user ||
      current_user.id == sshk.user.id ||
      current_user.lead?
    end
    sshkeys.map { |s| s.id }
  end

  # Add shortname attribute
  #
  # @return [Hash{Symbol => String}]
  def attributes(*args)
    data = super
    data[:shortname] = "#{object.firstname[0].upcase}. #{object.lastname}"
    data
  end
end
