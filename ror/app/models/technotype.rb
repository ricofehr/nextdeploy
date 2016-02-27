class Technotype < ActiveRecord::Base
  has_many :technos, dependent: :destroy
end
