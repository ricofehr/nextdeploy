module API
  module V1
    # Hpmessage controller for the rest API (V1).
    # Actually, Hpmessage objects are managed directly in database.
    # Controller is needed only for display properties into json format for rest compliance
    #
    # @author Eric Fehr (ricofehr@nextdeploy.io, github: ricofehr)
    class HpmessagesController < ApplicationController
      # set hpmessage object before show function
      before_action :set_hpmessage, only: [:show]

      # List all hpmessage objects
      #
      def index
        @hpmessages = Hpmessage.all_relevant(@user.access_level)

        respond_to do |format|
          format.json { render json: @hpmessages, status: 200 }
        end
      end

      # Display details about one hpmessage object
      #
      def show
        respond_to do |format|
          format.json { render json: @hpmessage, status: 200 }
        end
      end

      private

      # Init current object
      #
      def set_hpmessage
        @hpmessage = Hpmessage.find(params[:id])
      end

    end
  end
end
