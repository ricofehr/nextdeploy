# This class format systemimage type properties for json output
#
# @author Eric Fehr (ricofehr@nextdeploy.io, github: ricofehr)
class SystemimagetypeSerializer < ActiveModel::Serializer
  attributes :id, :name
  delegate :current_user, to: :scope

  has_many :systemimages, key: :systemimages

  # dont display systemimages if user is not allowed for
  def systemimages
    if current_user.admin?
      object.systemimages
    elsif current_user.lead?
      object.systemimages.select { |systemimage| systemimage.vms.select { |vm| !vm.user.admin? && vm.project.users.include?(current_user) }.size > 0 }
    else
      object.systemimages.select { |systemimage| systemimage.vms.select {|vm| vm.user.id == current_user.id }.size > 0 }
    end
  end
end
