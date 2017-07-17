# This class format project properties for json output
#
# @author Eric Fehr (ricofehr@nextdeploy.io, github: ricofehr)
class ProjectSerializer < ActiveModel::Serializer
  attributes :id, :name, :gitpath, :enabled, :login, :password, :created_at, :is_ht
  delegate :current_user, to: :scope

  has_one :brand, key: :brand
  has_one :owner, key: :owner
  has_many :users, key: :users
  has_many :endpoints, key: :endpoints
  has_many :technos, key: :technos
  has_many :vmsizes, key: :vmsizes
  has_many :systemimages, key: :systemimages
  has_many :branches, key: :branches

  # HACK return brand id (no embed option in AMS 0.10)
  #
  # @return [Number]
  def brand
    object.brand.id
  end

  # Filter owner record for current user
  # HACK return owner id (no embed option in AMS 0.10)
  #
  # @return [Number]
  def owner
    if object.owner && (current_user.lead? || object.owner.id == current_user.id)
      object.owner.id
    else
      nil
    end
  end

  # Filter user records for current user
  # HACK return ids list (no embed option in AMS 0.10)
  #
  # @return [Array<Number>]
  def users
    users = []
    if current_user.lead?
      users = object.users.select { |u| u.id != current_user.id }
      users = users.unshift(current_user)
    elsif current_user.dev?
      vms_v = object.vms.select { |vm| vm.is_jenkins }
      users = vms_v.flat_map(&:user).uniq.select { |u| u.id != current_user.id }
      users = users.unshift(current_user)
    else
      users <<= current_user
    end
    users.map { |u| u.id }
  end

  # HACK return endpoint ids list (no embed option in AMS 0.10)
  #
  # @return [Array<Number>]
  def endpoints
    object.endpoints.map { |e| e.id }
  end

  # HACK return techno ids list (no embed option in AMS 0.10)
  #
  # @return [Array<Number>]
  def technos
    object.technos.map { |t| t.id }
  end

  # HACK return vmsize ids list (no embed option in AMS 0.10)
  #
  # @return [Array<Number>]
  def vmsizes
    object.vmsizes.map { |v| v.id }
  end

  # HACK return systemimage ids list (no embed option in AMS 0.10)
  #
  # @return [Array<Number>]
  def systemimages
    object.systemimages.map { |s| s.id }
  end

  # HACK return branche ids list (no embed option in AMS 0.10)
  #
  # @return [Array<Number>]
  def branches
    object.branches.map { |b| b.id }
  end

  # Gitpath needs string changes
  #
  # @return [Hash{Symbol => String}]
  def attributes(*args)
    data = super
    gitlab_endpoint0 = Rails.application.config.gitlab_endpoint0
    data[:gitpath] = gitlab_endpoint0.gsub(/https?:\/\//, '') << ':/root/' << data[:gitpath]
    data
  end
end
