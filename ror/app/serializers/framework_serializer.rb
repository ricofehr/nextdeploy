# This class format framework properties for json output
#
# @author Eric Fehr (ricofehr@nextdeploy.io, github: ricofehr)
class FrameworkSerializer < ActiveModel::Serializer
  attributes :id, :name, :publicfolder, :rewrites, :dockercompose
  delegate :current_user, to: :scope

  has_many :endpoints, key: :endpoints
  has_many :uris, key: :uris

  # Filter endpoint records for current user
  # HACK return ids list (no embed option in AMS 0.10)
  #
  # @return [Array<Number>]
  def endpoints
    endpoints = object.endpoints
    unless current_user.admin?
      endpoints = object.endpoints.select { |ep| ep.project.users.include?(current_user) }
    end
    endpoints.map { |e| e.id }
  end

  # Filter uri records for current user
  # HACK return ids list (no embed option in AMS 0.10)
  #
  # @return [Array<Number>]
  def uris
    uris = []
    if current_user.admin?
      uris = object.uris
    elsif current_user.lead?
      uris = object.uris.select { |uri| uri.vm.project.users.include?(current_user) }
    else
      uris = object.uris.select { |uri| uri.vm.user.id == current_user.id }
    end
    uris.map { |u| u.id }
  end
end
