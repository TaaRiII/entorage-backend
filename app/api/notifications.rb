class Notifications < Grape::API
  include Authentication
  resource :notifications do
      desc 'send_notification'
      params do
        requires :auth_token, type: String, desc: 'Auth Token'
        requires :message, type: String, desc: 'message'
        requires :type, type: String, values: ["normal", "silent"], desc: ' type'
        requires :notifiable_type, type: String, values: %w[FriendshipRequest FriendshipAccepted GroupInvite GroupAdd GroupLeft GroupInviteAccepted GroupInviteDeclined GroupInviteDeleted GroupInviteNew GroupAddNew GroupStatusChanged MatchCreated UnMatch Message ProfilePicUpdated]
        requires :notifiable_id, type: String, desc: 'Notifiable ID'
      end
      post 'send_notification' do
        fcm_tokens = current_user.devices.pluck(:fcm_token).uniq
        if fcm_tokens.present?
          if params[:type] == "normal"
            response = FirebaseNotification.firebase_notifications(fcm_tokens, params[:notifiable_type], params[:notifiable_id], params[:message], false)
          elsif params[:type] == "silent"
            response  = FirebaseNotification.firebase_silent_notifications(fcm_tokens, params[:notifiable_type], params[:notifiable_id], params[:message])
          else
            puts"Facing Error in fcm_token not present!!! "
          end
          render :response => response[:body].as_json
        else
          error!('No Device present for user: '+ current_user.first_name.to_s, 401)
        end

      end

  end
end
