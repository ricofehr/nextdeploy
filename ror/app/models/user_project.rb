# Just a Joint class between Project and User objects
#
# @author Eric Fehr (eric.fehr@publicis-modem.fr, github: ricofehr)
class UserProject < ActiveRecord::Base
  belongs_to :user
  belongs_to :project
end
