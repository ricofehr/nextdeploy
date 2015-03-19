# This class format flavor properties for json output
#
# @author Eric Fehr (eric.fehr@publicis-modem.fr, github: ricofehr)
class FlavorSerializer < ActiveModel::Serializer
  attributes :id, :title, :description

  has_many :projects, key: :projects
end
