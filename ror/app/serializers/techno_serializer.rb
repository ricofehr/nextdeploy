# This class format techno properties for json output
#
# @author Eric Fehr (eric.fehr@publicis-modem.fr, github: ricofehr)
class TechnoSerializer < ActiveModel::Serializer
  attributes :id, :name, :puppetclass, :hiera

  has_many :projects, key: :projects
end
