class FirebaseNotification
  def self.firebase_notifications(fcm_tokens, notifiable_type, notifiable_id, message, title = nil, extra_data = nil)
    # fcm_tokens = ["cGHI-2ODWak:APA91bFJQB03H5jrx8T3mk1uxz_LzQ9PdcGecQHIfcNEClJrBNE4Fq-jUAQw3rTeT6KyhFZUQqIkGdLxt-qbhQMUyWKQGTxgPje6354d58i9IrGmMXbge2aOs7N5FkW3Mc0_DQZYbeOf"]

    server_key = 'AAAAqxU8VBM:APA91bF1pMyixWdlGVn5MnvK1g0Oo4TTmmAA1NsJOkbMkuud21Q-p9e5mIyW-ZYmhbbcf_ZZ4MsYcPEyjO9WA6ZLacVPkNoi52gz6mBj9C0UsaELlPHf5zj6fKWkMxaUpNacmNbwTHP1'
    fcm = FCM.new(server_key)
    # title = notifiable_type if title.nil?
    title = "Entourage"
    if notifiable_type.to_s == "General"
      title = "🕶 Team Entourage"
    end
    options =
    {
      content_available: true,
      priority: "high",
      notification:{
        title: title,
        body: message,
        sound: FirebaseNotification.sound_file_name(notifiable_type)
      },
      data:
      {
        notifiable_type: notifiable_type,
        notification_type: 'normal',
        notifiable_id: notifiable_id,
        extra_data: extra_data,
        message: message
      }
    }
    fcm.send(fcm_tokens, options)
  end

  def self.firebase_silent_notifications(fcm_tokens, notifiable_type, notifiable_id, message, title = nil, extra_data = nil)
    # fcm_tokens = ["e6aEQth5yAQ:APA91bGb_P2FUfdWu4MQmfv2ICW65gzIP6G0qzlRXKMs-ypj8VOt5Uhu3jVHv3RAr_BMW8cS9moDxoAAwFzkNX0L4gI92xQN6_Yu4ZC8XIkR3txF46hoXuLH7Stqk2J37SMesX1GTx-n"]
    fcm_tokens = fcm_tokens.reject { |e| e.to_s.empty? }

    server_key = 'AAAAqxU8VBM:APA91bF1pMyixWdlGVn5MnvK1g0Oo4TTmmAA1NsJOkbMkuud21Q-p9e5mIyW-ZYmhbbcf_ZZ4MsYcPEyjO9WA6ZLacVPkNoi52gz6mBj9C0UsaELlPHf5zj6fKWkMxaUpNacmNbwTHP1'
    fcm = FCM.new(server_key)
    options =
    {
      content_available: true,
      priority: "high",
      data:
      {
        notifiable_type: notifiable_type,
        notification_type: 'silent',
        notifiable_id: notifiable_id,
        extra_data: extra_data,
        message: message
      }
    }
    fcm.send(fcm_tokens, options)
  end

  def self.sound_file_name notification_type
    case notification_type
    when "MatchCreated"
      "newmatch.wav"
    else
      "message.wav"
    end
  end

end
