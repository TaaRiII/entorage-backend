class Devices < Grape::API
  include Authentication
  resource :devices do
      desc 'Update Device Token'
      params do
        requires :auth_token, type: String, desc: 'Auth Token'
        requires :physical_address, type: String, desc: 'device physical address'
        requires :fcm_token, type: String, desc: 'fcm token'
        requires :device_type, type: String,  values: ["iphone", "android"], desc: 'device type [iphone,android]'
      end
      post 'update_device_token' do
        # d = Device.where(physical_address: params[:physical_address]).first_or_initialize
        d = current_user.devices.first_or_initialize
        d.physical_address = params[:physical_address]
        d.user_id = current_user.id
        d.fcm_token = params[:fcm_token]
        d.device_type = params[:device_type]
        d.save
        render :message => "Successful".as_json
      end

  end
end
