# This class format user properties for json output
#
# @author Eric Fehr (eric.fehr@publicis-modem.fr, github: ricofehr)
class UserSerializer < ActiveModel::Serializer
  attributes :id, :email, :authentication_token, :is_project_create, :company, :quotavm, :firstname, :lastname, :created_at
  delegate :current_user, to: :scope

  has_many :vms, key: :vms
  has_many :sshkeys, key: :sshkeys
  has_one :group, key: :group
  has_many :projects, key: :projects
  has_many :own_projects, key: :own_projects

  # avoid for no lead/admin users to see other users details
  def projects
    object.projects.select { |project| !current_user || project.users.include?(current_user) }
  end

  def own_projects
    if !current_user || current_user.admin? || object.id == current_user.id
      object.own_projects
    else
      []
    end
  end

  def vms
    object.vms.select { |vm| !current_user || vm.project.users.include?(current_user) }
  end
end
