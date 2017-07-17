# This class format branche properties for json output
#
# @author Eric Fehr (ricofehr@nextdeploy.io, github: ricofehr)
class BrancheSerializer < ActiveModel::Serializer
  attributes :id, :name

  has_one :project, key: :project
  has_many :commits, key: :commits

  # HACK return project id (no embed option in AMS 0.10)
  #
  # @return [Number]
  def project
    object.project.id
  end

  # HACK return commit ids list (no embed option in AMS 0.10)
  #
  # @return [Array<Number>]
  def commits
    object.commits.map { |c| c.id }
  end
end
