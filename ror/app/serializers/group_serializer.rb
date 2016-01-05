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
    else
      [] << current_user
    end
  end
end
