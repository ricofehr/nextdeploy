# This class format vmsize properties for json output
#
# @author Eric Fehr (eric.fehr@publicis-modem.fr, github: ricofehr)
class VmsizeSerializer < ActiveModel::Serializer
  attributes :id, :title, :description

  has_many :projects, key: :projects
  has_many :vms, key: :vms
end
