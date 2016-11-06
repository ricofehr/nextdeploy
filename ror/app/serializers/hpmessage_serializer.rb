class HpmessageSerializer < ActiveModel::Serializer
  attributes :id, :title, :message, :ordering, :is_twitter, :date
end
