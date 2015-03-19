# This class format systemimage properties for json output
#
# @author Eric Fehr (eric.fehr@publicis-modem.fr, github: ricofehr)
class SystemimageSerializer < ActiveModel::Serializer
  attributes :id, :name, :glance_id, :enabled

  has_one :systemimagetype, key: :systemimagetype
  has_many :vms, key: :vms
end
