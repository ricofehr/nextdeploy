# This class format systemimage type properties for json output
#
# @author Eric Fehr (eric.fehr@publicis-modem.fr, github: ricofehr)
class SystemimagetypeSerializer < ActiveModel::Serializer
  attributes :id, :name
  delegate :current_user, to: :scope

  has_many :systemimages, key: :systemimages
  has_many :projects, key: :projects

  # dont display projects if user is not allowed for
  def projects
    if current_user.admin?
      object.projects
    else
      object.projects.select { |project| project.users.include?(current_user) }
    end
  end

  # dont display systemimages if user is not allowed for
  def systemimages
    if current_user.admin?
      object.systemimages
    elsif current_user.lead?
      object.systemimages.select { |systemimage| systemimage.vms.select { |vm| ! vm.user.admin? && vm.project.users.include?(current_user) }.length > 0 }
    else
      object.systemimages.select { |systemimage| systemimage.vms.select {|vm| vm.user.id == current_user.id }.length > 0 }
    end
  end
end
