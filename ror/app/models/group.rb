# A group sets common property for same type of users
#
# @author Eric Fehr (ricofehr@nextdeploy.io, github: ricofehr)
class Group < ActiveRecord::Base
  has_many :users, dependent: :destroy

  # Name is mandatory
  validates :name, presence: true

  # Return true if admin
  #
  # @return [Boolean] if admin
  def admin?
    access_level > 40
  end

  # Return true if lead
  #
  # @return [Boolean] if admin or lead
  def lead?
    access_level > 30
  end

  # Return true if dev
  #
  # @return [Boolean] if admin or lead or dev
  def dev?
    access_level > 20
  end
end
