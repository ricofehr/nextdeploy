# This class format vm properties for json output
#
# @author Eric Fehr (ricofehr@nextdeploy.io, github: ricofehr)
class VmSerializer < ActiveModel::Serializer
  attributes :id, :nova_id, :floating_ip, :vnc_url, :thumb, :created_at, :name, :topic,
             :status, :is_auth, :htlogin, :htpassword, :termpassword, :layout, :is_prod,
             :is_cached, :is_ht, :is_ci, :is_backup, :is_cors, :is_ro, :is_jenkins, :is_offline

  has_one :user, key: :user
  has_one :commit, key: :commit
  has_one :project, key: :project
  has_one :vmsize, key: :vmsize
  has_one :systemimage, key: :systemimage
  has_many :technos, key: :technos
  has_many :uris, key: :uris
  has_many :supervises, key: :supervises

  # Alias for buildtime
  #
  # @return [Number]
  def status
    object.buildtime
  end

  # HACK return user id (no embed option in AMS 0.10)
  #
  # @return [Number]
  def user
    object.user.id
  end

  # HACK return commit id (no embed option in AMS 0.10)
  #
  # @return [Number]
  def commit
    object.commit.id
  end

  # HACK return project id (no embed option in AMS 0.10)
  #
  # @return [Number]
  def project
    object.project.id
  end

  # HACK return vmsize id (no embed option in AMS 0.10)
  #
  # @return [Number]
  def vmsize
    object.vmsize.id
  end

  # HACK return systemimage id (no embed option in AMS 0.10)
  #
  # @return [Number]
  def systemimage
    object.systemimage.id
  end

  # HACK return techno ids list (no embed option in AMS 0.10)
  #
  # @return [Array<Number>]
  def technos
    object.technos.map { |t| t.id }
  end

  # HACK return uri ids list (no embed option in AMS 0.10)
  #
  # @return [Array<Number>]
  def uris
    object.uris.map { |u| u.id }
  end

  # HACK return supervise ids list (no embed option in AMS 0.10)
  #
  # @return [Array<Number>]
  def supervises
    object.supervises.map { |s| s.id }
  end

  # Define gitpath with suffix
  #
  # @return [Hash{Symbol => String}]
  def attributes(*args)
    data = super
    data[:name] <<= Rails.application.config.os_suffix
    data
  end
end
