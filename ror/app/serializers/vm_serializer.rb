# This class format vm properties for json output
#
# @author Eric Fehr (ricofehr@nextdeploy.io, github: ricofehr)
class VmSerializer < ActiveModel::Serializer
  attributes :id, :nova_id, :floating_ip, :vnc_url, :created_at, :name, :status,
             :is_auth, :htlogin, :htpassword, :termpassword, :layout, :is_prod,
             :is_cached, :is_ht, :is_ci, :is_backup, :is_cors

  # gitpath needs post string actions
  def attributes
    data = super
    data[:name] <<= Rails.application.config.os_suffix
    data
  end

  def status
    object.buildtime
  end

  has_many :technos, key: :technos
  has_many :uris, key: :uris
  has_one :commit, key: :commit
  has_one :project, key: :project
  has_one :vmsize, key: :vmsize
  has_one :user, key: :user
  has_one :systemimage, key: :systemimage
end
