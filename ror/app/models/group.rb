# A group sets common property for same type of users
#
# @author Eric Fehr (eric.fehr@publicis-modem.fr, github: ricofehr)
class Group < ActiveRecord::Base
  has_many :users, dependent: :destroy

  # Name is mandatory
  validates :name, presence: true
  
  # Return true if admin
  #
  # No param
  # @return [Boolean] if admin
  def admin?
    self.access_level > 40
  end

  # Return true if lead
  #
  # No param
  # @return [Boolean] if admin or lead
  def lead?
    self.access_level > 30
  end

end
