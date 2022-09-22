class Photos < Grape::API
  include Authentication
  resource :photos do
    #upload photo
    desc 'Upload New Photo'
    params do
      requires :auth_token, type: String, desc: 'Auth Token'
      requires :image, type: File, desc: 'Image'
      optional :is_primary, type: Boolean
      optional :order, type: Integer, desc: 'Image Order'
    end
    post 'upload_photo' do
      old_primary = current_user.photos.where(is_primary: true).first
      if params[:is_primary] && old_primary.present?
        old_primary.image = params[:image]
        old_primary.save
      else
        unless current_user.photos.count>=6
          permitted_params.delete :auth_token
          current_user.photos.create(permitted_params)
        else
          error!('Maximum limit of uploading Photos are already reached. ', 401)
        end
      end
      current_user
    end

    #delete photo

    desc 'Delete Photo'
    params do
      requires :auth_token, type: String, desc: 'Auth Token'
      requires :id, type: Integer, desc: 'Image Id'
    end
    delete 'delete_photo' do
      photo = current_user.photos.find_by_id(params[:id])
      if photo.present?
        error!('You cannot delete profile picture', 401) if photo.is_primary
        unless photo.is_ever_primary
          photo.image.clear(*[:medium, :thumb, :original])
          photo.save
        end
        photo.destroy
      else
        error!('Photo doesnot exist with given Id ', 401)
      end
      current_user
    end

    #Set Order
    desc 'Set Order of Photo and update primary'
    params do
      requires :auth_token, type: String, desc: 'Auth Token'
      requires :id, type: Integer, desc: 'Image Id'
      requires :order, type: Integer, desc: 'Image Order'
      optional :is_primary, type: Boolean
    end
    post 'set_order' do
        photo = current_user.photos.find_by_id(params[:id])
        old_primary = nil
        if photo.present?
          old_photo = current_user.photos.where(order: permitted_params[:order]).first
          old_photo.update_attributes(order: photo.order, is_primary: photo.is_primary) if old_photo.present?
          #get latest copy of photo
          photo.reload
          photo.order = permitted_params[:order] if permitted_params[:order].present?
          photo.is_primary = params[:is_primary] unless params[:is_primary].nil?
          photo.save
          current_user
        else
          error!('Photo doesnot exist with given Id ', 401)
        end
    end

  end
end
