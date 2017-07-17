# This class format vm properties for json output
#
# @author Eric Fehr (ricofehr@nextdeploy.io, github: ricofehr)
class VmSerializer < ActiveModel::Serializer
  attributes :id, :nova_id, :floating_ip, :vnc_url, :thumb, :created_at, :name, :topic,
             :status, :is_auth, :htlogin, :htpassword, :termpassword, :layout, :is_prod,
             :is_cached, :is_ht, :is_ci, :is_backup, :is_cors, :is_ro, :is_jenkins, :is_offline

  has_many :technos, key: :technos
  has_many :uris, key: :uris
  has_many :supervises, key: :supervises
  has_one :commit, key: :commit
  has_one :project, key: :project
  has_one :vmsize, key: :vmsize
  has_one :user, key: :user
  has_one :systemimage, key: :systemimage

  # Define gitpath with suffix
  #
  # @return [Hash{Symbol => String}]
  def attributes
    data = super
    data[:name] <<= Rails.application.config.os_suffix
    data
  end

  # Alias for buildtime
  #
  # @return [Number]
  def status
    object.buildtime
  end
end
