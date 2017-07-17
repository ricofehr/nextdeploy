# This class format project properties for json output
#
# @author Eric Fehr (ricofehr@nextdeploy.io, github: ricofehr)
class ProjectSerializer < ActiveModel::Serializer
  attributes :id, :name, :gitpath, :enabled, :login, :password, :created_at, :is_ht
  delegate :current_user, to: :scope

  has_many :users, key: :users
  has_many :endpoints, key: :endpoints
  has_many :technos, key: :technos
  has_many :vmsizes, key: :vmsizes
  has_many :systemimages, key: :systemimages
  has_many :branches, key: :branches
  has_one :owner, key: :owner
  has_one :brand, key: :brand

  # Filter user records for current user
  #
  # @return [Array<User>]
  def users
    if current_user.lead?
      users_a = object.users.select { |u| u.id != current_user.id }
      users_a.unshift(current_user)
    elsif current_user.dev?
      vms_v = object.vms.select { |vm| vm.is_jenkins }
      users_a = vms_v.flat_map(&:user).uniq.select { |u| u.id != current_user.id }
      users_a.unshift(current_user)
    else
      [] << current_user
    end
  end

  # Filter owner record for current user
  #
  # @return [User]
  def owner
    if current_user.lead? || (object.owner && object.owner.id == current_user.id)
      object.owner
    else
      nil
    end
  end

  # Gitpath needs string changes
  #
  # @return [Hash{Symbol => String}]
  def attributes
    data = super
    gitlab_endpoint0 = Rails.application.config.gitlab_endpoint0
    data[:gitpath] = gitlab_endpoint0.gsub(/https?:\/\//, '') << ':/root/' << data[:gitpath]
    data
  end
end
