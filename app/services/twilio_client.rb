class TwilioClient
  attr_reader :client

  def initialize
    @client = Twilio::REST::Client.new("ACa335ff8fa91c5a7b552e636b94565513", "bdc36dbab8c8dda7eb770292da13d6b4")
  end

  def send_text(user, to_phone_number, link)
    client.api.account.messages.create(
      to: to_phone_number,
      from: '+13343758754',
      body: "#{user.first_name} invites you to join their personal entourage. You can now download and use the app with them here \n\n#{ENV['app_url']}, #{link}"
      # body: "You’re in! 😎 \n\n#{user.full_name} has vouched you into their entourage. You can now download and use the app with them here \n\n#{ENV['app_url']}"
    )
  end
end