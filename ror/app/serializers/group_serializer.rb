# This class format group properties for json output
#
# @author Eric Fehr (ricofehr@nextdeploy.io, github: ricofehr)
class GroupSerializer < ActiveModel::Serializer
  attributes :id, :name, :access_level
  delegate :current_user, to: :scope

  has_many :users, key: :users

  # Filter user records for current user
  # HACK return ids list (no embed option in AMS 0.10)
  #
  # @return [Array<Number>]
  def users
    users = []
    if current_user.admin?
      users = object.users.select { |u| u.id != current_user.id }
      users.unshift(current_user) if object.id == current_user.group.id
    elsif current_user.lead?
      users = current_user.projects.flat_map(&:users).uniq.select do |u|
        u.id != current_user.id && u.group.id == object.id
      end
      users.unshift(current_user) if object.id == current_user.group.id
    elsif current_user.dev?
      vms = current_user.projects.flat_map(&:vms).uniq.select { |vm| vm.is_jenkins }
      users = vms.flat_map(&:user).uniq.select do |u|
        u.id != current_user.id && u.group.id == object.id
      end
      users.unshift(current_user) if object.id == current_user.group.id
    else
      users = [] << current_user if object.id == current_user.group.id
    end

    users.map { |u| u.id }
  end
end
