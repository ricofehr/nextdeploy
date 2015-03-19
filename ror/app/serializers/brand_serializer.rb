# This class format brand properties for json output
#
# @author Eric Fehr (eric.fehr@publicis-modem.fr, github: ricofehr)
class BrandSerializer < ActiveModel::Serializer
  attributes :id, :name, :logo

  has_many :projects, key: :projects
end