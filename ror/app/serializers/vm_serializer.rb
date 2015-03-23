# This class format vm properties for json output
#
# @author Eric Fehr (eric.fehr@publicis-modem.fr, github: ricofehr)
class VmSerializer < ActiveModel::Serializer
  attributes :id, :nova_id, :floating_ip, :created_at, :name

  # gitpath needs post string actions
  def attributes
    data = super
    data[:name] <<= Rails.application.config.os_suffix
    data
  end

  has_one :commit, key: :commit
  has_one :project, key: :project
  has_one :vmsize, key: :vmsize
  has_one :user, key: :user
  has_one :systemimage, key: :systemimage
end
