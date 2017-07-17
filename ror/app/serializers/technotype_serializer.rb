# This class format techno type properties for json output
#
# @author Eric Fehr (ricofehr@nextdeploy.io, github: ricofehr)
class TechnotypeSerializer < ActiveModel::Serializer
  attributes :id, :name
  delegate :current_user, to: :scope

  has_many :technos, key: :technos

  # Sort techno records
  #
  # @return [Array<Techno>]
  def technos
    object.technos.sort_by(&:id).reverse
  end
end
