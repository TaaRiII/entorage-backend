class Admin::DevicesController < ApplicationController
  layout "admin"
  expose :devices, -> {Device.all}
  expose :device

  def index
   @q = Device.ransack(params[:device_query], search_key: :device_query)
    self.devices = @q.result.includes(:user).page(params[:page])
  end

  def show
    respond_to do |format|
      format.js { render layout: false }
    end
  end

  def destroy
    device.destroy
    redirect_to(admin_devices_path)
  end
end
