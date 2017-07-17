# This class format brand properties for json output
#
# @author Eric Fehr (ricofehr@nextdeploy.io, github: ricofehr)
class BrandSerializer < ActiveModel::Serializer
  attributes :id, :name, :logo
  delegate :current_user, to: :scope

  has_many :projects, key: :projects

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
end
