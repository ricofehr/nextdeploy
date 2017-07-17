# This class format commit properties for json output
#
# @author Eric Fehr (ricofehr@nextdeploy.io, github: ricofehr)
class CommitSerializer < ActiveModel::Serializer
  attributes :id, :commit_hash, :short_id, :title, :author_name,
             :author_email, :message, :created_at
  delegate :current_user, to: :scope

  has_one :branche, key: :branche
  has_many :vms, key: :vms

  # Filter vm records for current user
  #
  # @return [Array<Vm>]
  def vms
    if current_user.admin?
      object.vms
    elsif current_user.lead?
      object.vms.select { |vm| vm.project.users.include?(current_user) }
    elsif current_user.dev?
      object.vms.select { |vm| vm.user.id == current_user.id || vm.is_jenkins }
    else
      object.vms.select { |vm| vm.user.id == current_user.id }
    end
  end
end
