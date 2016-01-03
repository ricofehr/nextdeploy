# This class format commit properties for json output
#
# @author Eric Fehr (ricofehr@nextdeploy.io, github: ricofehr)
class CommitSerializer < ActiveModel::Serializer
  attributes :id, :commit_hash, :short_id, :title, :author_name, :author_email, :message, :created_at
  delegate :current_user, to: :scope

  has_one :branche, key: :branche
  has_many :vms, key: :vms

  # dont display vms if user is not allowed for
  def vms
    if current_user.admin?
      object.vms
    elsif current_user.lead?
      object.vms.select { |vm| ! vm.user.admin? && vm.project.users.include?(current_user) }
    else
      object.vms.select { |vm| vm.user.id == current_user.id }
    end
  end
end
