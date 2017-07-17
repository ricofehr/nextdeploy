# This class format commit properties for json output
#
# @author Eric Fehr (ricofehr@nextdeploy.io, github: ricofehr)
class CommitSerializer < ActiveModel::Serializer
  attributes :id, :commit_hash, :short_id, :title, :author_name,
             :author_email, :message, :created_at
  delegate :current_user, to: :scope

  has_one :branche, key: :branche
  has_many :vms, key: :vms

  # HACK return branche id (no embed option in AMS 0.10)
  #
  # @return [Number]
  def branche
    object.branche.id
  end

  # Filter vm records for current user
  # HACK return ids list (no embed option in AMS 0.10)
  #
  # @return [Array<Number>]
  def vms
    vms = []
    if current_user.admin?
      vms = object.vms
    elsif current_user.lead?
      vms = object.vms.select { |vm| vm.project.users.include?(current_user) }
    elsif current_user.dev?
      vms = object.vms.select { |vm| vm.user.id == current_user.id || vm.is_jenkins }
    else
      vms = object.vms.select { |vm| vm.user.id == current_user.id }
    end
    vms.map { |v| v.id }
  end
end
