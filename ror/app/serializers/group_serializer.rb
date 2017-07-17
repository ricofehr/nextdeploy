# This class format group properties for json output
#
# @author Eric Fehr (ricofehr@nextdeploy.io, github: ricofehr)
class GroupSerializer < ActiveModel::Serializer
  attributes :id, :name, :access_level
  delegate :current_user, to: :scope

  has_many :users, key: :users

  # Filter user records for current user
  #
  # @return [Array<User>]
  def users
    users_a = []
    if current_user.admin?
      users_a = object.users.select { |u| u.id != current_user.id }
      users_a.unshift(current_user) if object.id == current_user.group.id
    elsif current_user.lead?
      users_a = current_user.projects.flat_map(&:users).uniq.select do |u|
        u.id != current_user.id && u.group.id == object.id
      end
      users_a.unshift(current_user) if object.id == current_user.group.id
    elsif current_user.dev?
      vms = current_user.projects.flat_map(&:vms).uniq.select { |vm| vm.is_jenkins }
      users_a = vms.flat_map(&:user).uniq.select do |u|
        u.id != current_user.id && u.group.id == object.id
      end
      users_a.unshift(current_user) if object.id == current_user.group.id
    else
      users_a = [] << current_user if object.id == current_user.group.id
    end

    users_a
  end
end
