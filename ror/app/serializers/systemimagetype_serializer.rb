# This class format systemimage type properties for json output
#
# @author Eric Fehr (eric.fehr@publicis-modem.fr, github: ricofehr)
class SystemimagetypeSerializer < ActiveModel::Serializer
  attributes :id, :name

  has_many :systemimages, key: :systemimages
  has_many :projects, key: :projects
end
