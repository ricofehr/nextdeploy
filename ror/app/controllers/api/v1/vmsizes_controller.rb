module API
  module V1
    # Vmsize controller for the rest API (V1).
    # Actually, vmsize objects are managed directly in database.
    # Controller is needed only for display properties into json format for rest compliance
    #
    # @author Eric Fehr (ricofehr@nextdeploy.io, github: ricofehr)
    class VmsizesController < ApplicationController
      # set vmsize object before show function
      before_action :set_vmsize, only: [:show]

      # List all vmsizes
      #
      def index
        # select only objects allowed by current user
        if @user.lead?
          @vmsizes = Vmsize.all
        else
          @vmsizes = @user.projects.flat_map(&:vmsizes).uniq
        end

        # HACK need an AR array (even empty) for AMS
        @vmsizes = Vmsize.none if @vmsizes.length == 0

        respond_to do |format|
          format.json { render json: @vmsizes, status: 200 }
        end
      end

      # Details about one vmsize object
      #
      def show
        respond_to do |format|
          format.json { render json: @vmsize, status: 200 }
        end
      end

      private

      # Init current object
      #
      def set_vmsize
        @vmsize = Vmsize.find(params[:id])
      end

      # Never trust parameters from the scary internet, only allow the white list through.
      #
      def vmsize_params
        params.require(:vmsize).permit(:title, :description)
      end

    end
  end
end
