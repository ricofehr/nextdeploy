module API
  module V1
    # Sshkey controller for the rest API (V1).
    #
    # @author Eric Fehr (ricofehr@nextdeploy.io, github: ricofehr)
    class SshkeysController < ApplicationController
      # Hook who set sshkey object
      before_action :set_sshkey, only: [:show, :update, :destroy]

      # Format ember parameters into rails parameters
      before_action :ember_to_rails, only: [:create, :update]

      # Check user right for avoid no-authorized access
      before_action :check_rights, only: [:create, :destroy, :update, :show]

      # List all sshkey for one user
      #
      def index
        # Default is current user
        (params[:user_id]) ? (user_id = params[:user_id]) : (user_id = @user.id)
        @sshkeys = User.includes(:sshkeys).find(user_id).sshkeys

        respond_to do |format|
          format.json { render json: @sshkeys, status: 200 }
        end
      end

      # Display details about one ssh key
      #
      def show
        respond_to do |format|
          format.json { render json: @sshkey, status: 200 }
        end
      end

      # Create a new sshkey for one user
      #
      def create
        @sshkey = Sshkey.create!(sshkey_params)

        respond_to do |format|
          if @sshkey
            format.json { render json: @sshkey, status: 200 }
          else
            format.json { render json: nil, status: :unprocessable_entity }
          end
        end
      end

      # Apply change onto one ssh key object
      #
      def update
        respond_to do |format|
          if @sshkey.update(sshkey_params)
            format.json { render json: @sshkey, status: 200 }
          else
            format.json { render json: @sshkey.errors, status: :unprocessable_entity }
          end
        end
      end

      # Destroy one ssh key object
      #
      def destroy
        @sshkey.destroy
        respond_to do |format|
          format.json { head :no_content }
        end
      end

      private

      # HACK change ember parameter name for well rails relationships
      #
      def ember_to_rails
        params_p = params[:sshkey]
        params_p[:user_id] ||= params_p[:user]
        params_p.delete(:user)
        # normalize name value
        params_p[:name].tr!('^a-zA-Z-', '')
        params[:sshkey] = params_p
      end

      # Init current object
      #
      def set_sshkey
        @sshkey = Sshkey.includes(:user).find(params[:id])
      end

      # Never trust parameters from the scary internet, only allow the white list through.
      #
      def sshkey_params
        params.require(:sshkey).permit(:id, :name, :key, :user_id)
      end

      # check right for grant access
      #
      def check_rights
        sshkeys = @user.sshkeys
        if !@user.lead?
          # for update / destroy, check that the sshkey is owner by current user
          if (@sshkey && !sshkeys.include?(@sshkey))
              raise Exceptions::NextDeployException.new("Access forbidden for this user")
          end

          # for sshkey creation, check the user_id
          if (!@sshkey && params[:sshkey][:user_id].to_i != @user.id.to_i)
              raise Exceptions::NextDeployException.new("Access forbidden for this user")
          end
        end
      end

    end
  end
end
