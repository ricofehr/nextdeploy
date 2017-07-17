# This class format user properties for json output
#
# @author Eric Fehr (ricofehr@nextdeploy.io, github: ricofehr)
class UserSerializer < ActiveModel::Serializer
  attributes :id, :email, :authentication_token, :is_project_create, :is_user_create,
             :is_recv_vms, :company, :quotavm, :quotaprod, :nbpages, :layout, :firstname,
             :lastname, :created_at

  delegate :current_user, to: :scope

  has_many :vms, key: :vms
  has_many :sshkeys, key: :sshkeys
  has_one :group, key: :group
  has_many :projects, key: :projects
  has_many :own_projects, key: :own_projects

  # Add shortname attribute
  #
  # @return [Hash{Symbol => String}]
  def attributes
    data = super
    data[:shortname] = "#{object.firstname[0].upcase}. #{object.lastname}"
    data
  end

  # Give auth_token only for current user
  #
  # @return [String]
  def authentication_token
    object.authentication_token if !current_user || object.id == current_user.id
  end

  # Filter project records for current user
  #
  # @return [Array<Project>]
  def projects
    object.projects.select { |project| !current_user || project.users.include?(current_user) }
  end

  # Filter own_project records for current user
  #
  # @return [Array<Project>]
  def own_projects
    if !current_user || current_user.admin? || object.id == current_user.id
      object.own_projects
    else
      []
    end
  end

  # Filter vm records for current user
  #
  # @return [Array<Vm>]
  def vms
    object.vms.select do |vm|
      !current_user ||
      current_user.id == vm.user.id ||
      current_user.admin? ||
      (current_user.lead? && vm.project.users.include?(current_user)) ||
      (current_user.dev? && vm.project.users.include?(current_user) && vm.is_jenkins)
    end
  end

  # Filter sshkey records for current user
  #
  # @return [Array<Sshkey>]
  def sshkeys
    object.sshkeys.select do |sshk|
      !current_user ||
      current_user.id == sshk.user.id ||
      current_user.lead?
    end
  end
end
