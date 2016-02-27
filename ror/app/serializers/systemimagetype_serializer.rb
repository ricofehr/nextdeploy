# This class format systemimage type properties for json output
#
# @author Eric Fehr (ricofehr@nextdeploy.io, github: ricofehr)
class SystemimagetypeSerializer < ActiveModel::Serializer
  attributes :id, :name
  delegate :current_user, to: :scope

  has_many :systemimages, key: :systemimages
end
