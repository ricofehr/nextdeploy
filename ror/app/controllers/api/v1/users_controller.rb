module API
  module V1
    # User controller for the rest API (V1).
    #
    # @author Eric Fehr (eric.fehr@publicis-modem.fr, github: ricofehr)
    class UsersController < ApplicationController
      # Check user right for avoid no-authorized access
      before_action :check_lead, only: [:show_by_email, :index, :show, :update]
      # Hook who set user object
      before_action :set_user, only: [:show, :update, :destroy]
      # Check user right for avoid no-authorized access
      before_action :only_admin, only: [:create, :destroy]
      # Format ember parameters into rails parameters
      before_action :ember_to_rails, only: [:create, :update]

      # List all users
      def index
        if @user.admin?
          # Find users with project associated
          @users = User.includes(:projects).all

          # If project parameter, get all users for one project
          if project_id = params[:project_id]
            project = Project.find(project_id)
            @users = project.users
          end

          # If group parameter, get all users included into one group
          if group_id = params[:group_id]
            group = Group.find(group_id)
            @users = group.users
          end

        #filter by user_id for limited access
        else
          if @user.lead?
            @users = []
            projects = @user.projects
            if projects
              @users = projects.map { |project| project.users }
              @users.flatten!.uniq!
              @users.select! { |u| ! u.lead? || u.id == @user.id }
            end
          else
            @users = [] << User.includes(:projects).find(@user.id)
          end
        end

        # Json output
        respond_to do |format|
          format.json { render json: @users, status: 200 }
        end
      end

      # Details about one user
      def show
        # Jeson output
        respond_to do |format|
          format.json { render json: @user_c, status: 200 }
        end
      end

      # Details about current logged user (recorded into rails session)
      def show_current
        # Json output
        respond_to do |format|
          format.json { render json: @user, status: 200 }
        end
      end

      # return an user by email
      def show_by_email
        @user_c = User.find_by_email(params[:email])

        # Json output
        respond_to do |format|
          format.json { render json: @user_c, status: 200 }
        end
      end

      # return server ca
      def dl_openvpn_ca
        # download file
        respond_to do |format|
          format.text do
            render plain: @user.openvpn_ca, status: 200
          end
        end
      end

      # return openvpn key
      def dl_openvpn_key
        # download file
        respond_to do |format|
          format.text do
            render plain: @user.openvpn_key, status: 200
          end
        end
      end

      # return openvpn crt
      def dl_openvpn_crt
        # donwload file
        respond_to do |format|
          format.text do
            render plain: @user.openvpn_crt, status: 200
          end
        end
      end

      # return openvpn client conf
      def dl_openvpn_conf
        # donwload file
        respond_to do |format|
          format.text do
            render plain: @user.openvpn_conf, status: 200
          end
        end
      end

      # Create a new user
      def create
        @user_c = User.create!(user_params)

        # Json output (return error if issue occurs)
        respond_to do |format|
          if @user_c
            format.json { render json: @user_c, status: 200 }
          else
            format.json { render json: nil, status: :unprocessable_entity }
          end
        end
      end

      # Update user object
      def update
        # Json output (return error if issue occurs)
        respond_to do |format|
          if @user_c.update(user_params)
            @user_c.update_gitlabuser
            format.json { render json: @user_c, status: 200 }
          else
            format.json { render json: @user_c.errors, status: :unprocessable_entity }
          end
        end
      end

      # Destroy user object
      def destroy
        @user_c.destroy
        # Json output
        respond_to do |format|
          format.json { head :no_content }
        end
      end

      private

      # set user_c object (other user than current)
      def set_user
        if ! @user.lead?
          params[:id] = @user.id
        end

        @user_c = User.includes(:projects).find(params[:id])
      end

      # change ember parameter name for well rails relationships
      # houuuu que c est moche
      def ember_to_rails
        params_p = params[:user]

        params_p[:group_id] = params_p[:group]
        params_p[:project_ids] = params_p[:projects]

        if ((params_p[:password] && params_p[:password].empty?) ||
            (params_p[:password_confirmation] && params_p[:password_confirmation].empty?))
          params_p.delete(:password)
          params_p.delete(:password_confirmation)
        end

        params_p.delete(:created_at)
        params_p.delete(:authentication_token)
        params_p.delete(:group)
        params_p.delete(:projects)
        params_p.delete(:group_id) if ! @user.admin?
        params_p.delete(:quotavm) if ! @user.lead?
        params_p.delete(:project_ids) if ! @user.admin?

        params[:user] = params_p
      end

      # Never trust parameters from the scary internet, only allow the white list through.
      def user_params
        params.require(:user).permit(:email, :company, :quotavm, :firstname, :lastname, :password, :password_confirmation, :group_id, :project_ids => [])
      end
    end
  end
end