# This class format group properties for json output
#
# @author Eric Fehr (eric.fehr@publicis-modem.fr, github: ricofehr)
class GroupSerializer < ActiveModel::Serializer
  attributes :id, :name, :access_level
  delegate :current_user, to: :scope

  has_many :users, key: :users

  # avoid for no lead/admin users to see other users details
  def users
    if current_user.lead?
      object.users
    else
      [] << current_user
    end
  end
end
