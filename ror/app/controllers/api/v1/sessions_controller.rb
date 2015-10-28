module API
  module V1
    # Session controller for the rest API (V1).
    #
    # @author Eric Fehr (eric.fehr@publicis-modem.fr, github: ricofehr)
    class SessionsController < Devise::SessionsController
      before_filter :authenticate_api_v1_user!, :except => [:create]
      # Json output
      respond_to :json

      # Create a new session
      def create
        # check if email exists
        resource = User.find_for_database_authentication(email: params[:email])
        return invalid_login_attempt unless resource

        # check password
        if resource.valid_password?(params[:password])
          sign_in(:api_v1_user, resource)
          resource.ensure_authentication_token
          respond_to do |format|
            format.json { render json: resource, status: 200 }
          end

          return
        end

        # return error
        invalid_login_attempt
      end

      # Destroy current session
      def destroy
        resource = User.find_for_database_authentication(:email => params[:email])
        resource.authentication_token = nil
        resource.save
        render :json=> {:success=>true}
      end

      protected

      # Error function
      def invalid_login_attempt
        render :json=> {:success=>false, :message=>"Error with your login or password"}, :status=>401
      end
    end
  end
end
