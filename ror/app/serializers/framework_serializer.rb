# This class format framework properties for json output
#
# @author Eric Fehr (ricofehr@nextdeploy.io, github: ricofehr)
class FrameworkSerializer < ActiveModel::Serializer
  attributes :id, :name, :publicfolder, :rewrites
  delegate :current_user, to: :scope

  has_many :endpoints, key: :endpoints
  has_many :uris, key: :uris
  #has_many :projects, key: :projects

  # dont display endpoints if user is not allowed for
  def endpoints
   if current_user.admin?
     object.endpoints
   else
     object.endpoints.select { |ep| ep.project.users.include?(current_user) }
   end
  end

  # dont display uri if user is not allowed for
  def uris
   if current_user.admin?
     object.uris
   elsif current_user.lead?
     object.uris.select { |uri| uri.vm.project.users.include?(current_user) }
   else
     object.uris.select { |uri| uri.vm.user.id == current_user.id }
   end
  end
end
