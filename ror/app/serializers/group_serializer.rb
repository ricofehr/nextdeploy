# This class format group properties for json output
#
# @author Eric Fehr (ricofehr@nextdeploy.io, github: ricofehr)
class GroupSerializer < ActiveModel::Serializer
  attributes :id, :name, :access_level
  delegate :current_user, to: :scope

  has_many :users, key: :users

  # avoid for no lead/admin users to see other users details
  def users
    if current_user.admin?
      users_a = object.users.select { |u| u.id != current_user.id }
      users_a.unshift(current_user) if object.id == current_user.group.id
    elsif current_user.lead?
      users_a = current_user.projects.flat_map(&:users).uniq.select { |u| u.id != current_user.id && u.group.id == object.id }
      users_a.unshift(current_user) if object.id == current_user.group.id
    elsif current_user.dev?
      users_a = []
      vms = current_user.projects.flat_map(&:vms).uniq
      vms.select! { |vm| vm.is_jenkins } if vms.size
      users_a = vms.flat_map(&:user).uniq.select { |u| u.id != current_user.id && u.group.id == object.id } if vms.size
      users_a.unshift(current_user) if object.id == current_user.group.id
    else
      users_a = [] << current_user if object.id == current_user.group.id
    end

    if users_a.size != 0
      users_a
    else
      []
    end
  end
end
