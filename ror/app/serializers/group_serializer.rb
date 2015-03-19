# This class format group properties for json output
#
# @author Eric Fehr (eric.fehr@publicis-modem.fr, github: ricofehr)
class GroupSerializer < ActiveModel::Serializer
  attributes :id, :name, :access_level

  has_many :users, key: :users
end
