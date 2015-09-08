# This class format framework properties for json output
#
# @author Eric Fehr (eric.fehr@publicis-modem.fr, github: ricofehr)
class FrameworkSerializer < ActiveModel::Serializer
  attributes :id, :name, :publicfolder, :rewrites
  delegate :current_user, to: :scope

  has_many :projects, key: :projects

  # dont display projects if user is not allowed for
  def projects
    if current_user.admin?
      object.projects
    else
      object.projects.select { |project| project.users.include?(current_user) }
    end
  end
end
