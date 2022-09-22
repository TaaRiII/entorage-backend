class MatchSerializer < ActiveModel::Serializer
  attributes :id, :chat_id, :status
  has_one :matcher

  def chat_id
    object.chat_id.to_i
  end

end
