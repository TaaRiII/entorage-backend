class GroupStatusSerializer < ActiveModel::Serializer
  attributes :id, :name, :position, :status_type, :original,:medium,:thumb, :status_type, :distance

  def original
    object.icon.present? ? object.icon.url : nil
  end

  def medium
    object.icon.present? ? object.icon.url(:medium) : nil
  end

  def thumb
    object.icon.present? ? object.icon.url(:thumb) : nil
  end

  def distance
    distance = ""
    begin
      distance = object.distance.round(0)
      if distance  < 1
        distance = "1 mile"
      else
        distance = distance.to_s + " Mi."
      end
    rescue
    end
    distance
  end
end
