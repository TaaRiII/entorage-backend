class Admin::NotificationsController < ApplicationController
  layout "admin"
  expose :notifications, -> {Notification.all.order(id: :desc)}
  expose :notification
  def index
    @q = Notification.ransack(params[:q])
    self.notifications = @q.result(distinct: true).page(params[:page])
  end

 def show
    respond_to do |format|
      format.js { render layout: false }
    end
  end

  def create
    if notification.save
      message = ""
      fcm_tokens = notification.devices_list
      if fcm_tokens.present?

        fcm_tokens.each_slice(1000) do |fcm_tokens_chunk|
          FirebaseNotification.firebase_notifications(fcm_tokens_chunk, "General", "-1", notification.message)
        end

        message = "Notification Created"
      else
        message = "No Device assocated"
      end
      flash[:success]= message
      redirect_to admin_notifications_path
    else
      render :new
    end
  end

  def destroy
    notification.destroy
    redirect_to admin_notifications_path
    flash[:alert]= "Notification Deleted"
  end

  private
  def notification_params
    params.require(:notification).permit(:message, :user_ids=>[])
  end
end
