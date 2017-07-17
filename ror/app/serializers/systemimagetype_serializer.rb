# This class format systemimage type properties for json output
#
# @author Eric Fehr (ricofehr@nextdeploy.io, github: ricofehr)
class SystemimagetypeSerializer < ActiveModel::Serializer
  attributes :id, :name
  delegate :current_user, to: :scope

  has_many :systemimages, key: :systemimages

  # HACK return systemimage ids list (no embed option in AMS 0.10)
  #
  # @return [Array<Number>]
  def systemimages
    object.systemimages.map { |s| s.id }
  end
end
