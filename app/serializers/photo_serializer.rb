class PhotoSerializer < ActiveModel::Serializer
  attributes :id,:order, :is_primary, :original,:medium,:thumb

  def original
    object.image.present? ? object.image.url : nil
  end

  def medium
    object.image.present? ? object.image.url(:medium) : nil
  end

  def thumb
    object.image.present? ? object.image.url(:thumb) : nil
  end

end
