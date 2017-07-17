# This class format techno type properties for json output
#
# @author Eric Fehr (ricofehr@nextdeploy.io, github: ricofehr)
class TechnotypeSerializer < ActiveModel::Serializer
  attributes :id, :name
  delegate :current_user, to: :scope

  has_many :technos, key: :technos

  # Sort techno records
  # HACK return ids list (no embed option in AMS 0.10)
  #
  # @return [Array<Number>]
  def technos
    object.technos.sort_by(&:id).reverse.map { |t| t.id }
  end
end
