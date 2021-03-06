module API
  module V1
    # Group controller for the rest API (V1).
    #
    # @author Eric Fehr (ricofehr@nextdeploy.io, github: ricofehr)
    class GroupsController < ApplicationController
      # Hook who set group object
      before_action :set_group, only: [:show, :update, :destroy]

      # Check user right for avoid no-authorized access
      before_action :only_admin, only: [:create, :destroy, :update]

      # List all groups
      #
      def index
        # select only objects allowed by current user
        if @user.dev?
          @groups = Group.all
        else
          @groups = [] << @user.group
        end

        respond_to do |format|
          format.json { render json: @groups }
        end
      end

      # Display details about one group object
      #
      def show
        # if no lead, only current group
        if @user.lead?
          respond_to do |format|
            format.json { render json: @group }
          end
        else
          show_current
        end
      end

      # Display details about current group object (about current session)
      #
      def show_current
        respond_to do |format|
          format.json { render json: @user.group, status: 200 }
        end
      end

      # Create a new group object
      #
      def create
        @group = Group.new(group_params)

        respond_to do |format|
          if @group.save
            format.json { render json: @group, status: :created }
          else
            format.json { render json: @group.errors, status: :unprocessable_entity }
          end
        end
      end

      # Apply change for one group object
      #
      def update
        respond_to do |format|
          if @group.update(group_params)
            format.json { head :no_content }
          else
            format.json { render json: @group.errors, status: :unprocessable_entity }
          end
        end
      end

      # Destroy one group object
      #
      def destroy
        @group.destroy
        respond_to do |format|
          format.json { head :no_content }
        end
      end

      private

      # Init current object
      #
      def set_group
        @group = Group.find(params[:id])
      end

      # Never trust parameters from the scary internet, only allow the white list through.
      #
      def group_params
        params.require(:group).permit(:name, :access_level)
      end

    end
  end
end
