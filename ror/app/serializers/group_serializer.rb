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
      users_a = object.users.select { |u| u.id != current_user.id && u.projects.select { |project| project.users.include?(current_user) }.size > 0 }
      users_a.unshift(current_user) if object.id == current_user.group.id
    else
      [] << current_user
    end
  end
end
