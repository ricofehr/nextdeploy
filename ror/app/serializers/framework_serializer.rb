# This class format framework properties for json output
#
# @author Eric Fehr (eric.fehr@publicis-modem.fr, github: ricofehr)
class FrameworkSerializer < ActiveModel::Serializer
  attributes :id, :name, :publicfolder, :rewrites

  has_many :projects, key: :projects
end
