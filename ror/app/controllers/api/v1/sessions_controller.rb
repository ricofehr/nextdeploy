module API
  module V1
    # Session controller for the rest API (V1).
    #
    # @author Eric Fehr (ricofehr@nextdeploy.io, github: ricofehr)
    class SessionsController < Devise::SessionsController
      before_filter :authenticate_api_v1_user!, :except => [:create]
      # Json output
      respond_to :json

      # Create a new session
      #
      def create
        # check if email exists
        resource = User.find_for_database_authentication(email: params[:user][:email])
        return invalid_login_attempt unless resource

        # check password
        if resource.valid_password?(params[:user][:password])
          sign_in(:api_v1_user, resource)
          resource.ensure_authentication_token

          respond_to do |format|
            format.json { render json: { token: resource.authentication_token,
                                         email: resource.email,
                                         access_level: resource.access_level,
                                         user_id: resource.id,
                                         group_id: resource.group.id,
                                         user: resource }, status: 200 }
          end

          return
        end

        # return error
        invalid_login_attempt
      end

      # Destroy current session
      #
      def destroy
        authenticate_with_http_token do |user_token, options|
          resource = user_token && User.find_by_authentication_token(user_token)
          resource.reset_authentication_token! if resource
        end

        render json: {success: true}
      end

      protected

      # Error function
      #
      def invalid_login_attempt
        render json: {success: false, message: "Error with your login or password"}, status: 401
      end

    end
  end
end
