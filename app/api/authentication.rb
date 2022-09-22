module Authentication
  extend ActiveSupport::Concern
  included do

    before do
      authenticated?
    end

    helpers do
      def current_user
        resource = User.find_by(authentication_token: params[:auth_token])
      end

      def authenticated?
        error!('401 Unauthorized', 401) unless current_user
      end
    end
  end
end
