module API
  module V1
    # Systemimage controller for the rest API (V1).
    # Actually, Systemimage objects are managed directly in database.
    # Controller is needed only for display properties into json format for rest compliance
    #
    # @author Eric Fehr (ricofehr@nextdeploy.io, github: ricofehr)
    class SystemimagesController < ApplicationController
      # set systemimage object before show function
      before_action :set_systemimage, only: [:show]

      # List all systemimage objects
      def index
        @systemimages = Systemimage.all

        # If systemimagetype parameter, get all systemimages for one type
        if systemimagetype_id = params[:systemimagetype_id]
          systemimagetype = Systemimagetype.includes(:systemimages).find(systemimagetype_id)
          @systemimages = systemimagetype.systemimages
        end

        # Json output
        respond_to do |format|
            format.json { render json: @systemimages, status: 200 }
        end
      end

      # List all systemimage objects for one type of operating system
      def index_by_type
        systemimagetype = Systemimagetype.includes(:systemimages).find(params[:systemimagetype_id])
        @systemimages = systemimagetype.systemimages

        # Json output
        respond_to do |format|
            format.json { render json: @systemimages, status: 200 }
        end
      end

      # Display details about one systemimage object
      def show
        # Json output
        respond_to do |format|
            format.json { render json: @systemimage, status: 200 }
        end
      end


      private
        # Use callbacks to share common setup or constraints between actions.
        def set_systemimage
          @systemimage = Systemimage.find(params[:id])
        end

        # Never trust parameters from the scary internet, only allow the white list through.
        def systemimage_params
          params.require(:systemimage).permit(:name, :glance_id, :enabled)
        end
    end
  end
end
