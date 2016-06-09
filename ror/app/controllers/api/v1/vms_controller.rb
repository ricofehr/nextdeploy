module API
  module V1
    # VM controller for the rest API (V1).
    #
    # @author Eric Fehr (ricofehr@nextdeploy.io, github: ricofehr)
    class API::V1::VmsController < ApplicationController
      # except setupcomplet to rest auth
      before_filter :authenticate_user_from_token!, :except => [:setupcomplete, :resetpassword, :refreshcommit]
      before_filter :authenticate_api_v1_user!, :except => [:setupcomplete, :resetpassword, :refreshcommit]
      # Hook who set vm object
      before_action :set_vm, only: [:show, :update, :destroy, :check_status, :boot, :gitpull, :logs, :toggleauth, :toggleprod, :togglecached, :toggleht, :toggleci, :togglebackup, :postinstall_display, :postinstall]
      # Hook who check rights before action
      before_action :check_me, only: [:show, :update, :destroy, :check_status, :boot, :gitpull, :logs, :toggleauth, :toggleprod, :togglecached, :toggleht, :toggleci, :togglebackup, :postinstall_display, :postinstall]
      # Format ember parameters into rails parameters
      before_action :ember_to_rails, only: [:create, :update]
      # Check user right for avoid no-authorized access
      before_action :check_admin, only: [:create, :create_short, :destroy, :boot]
      # Hook who check ci right before tool action
      before_action :check_ci, only: [:gitpull, :postinstall]
      # Hook who reload ci right after tool action
      after_action :reload_ci, only: [:gitpull, :postinstall]
      

      # List all vms
      def index
        # select only objects allowed by current user
        if project_id = params[:project_id]
          if @user.lead?
            project = Project.find(project_id)
            @vms = project.vms if @user.projects.include?(project)
          else
            @vms = Vm.find_by_user_project(@user.id, project_id)
          end
        else
          if @user.admin?
            @vms = Vm.all
          else
            if @user.lead?
              projects = @user.projects
              if projects
                @vms = projects.flat_map(&:vms).uniq
                #@vms.select! { |v| !v.user.admin? }
              end
            else
              @vms = @user.vms
            end
          end
        end

        # Json format
        respond_to do |format|
            format.json { render json: @vms || [], status: 200 }
        end
      end

      # Create a new vm request
      def create
        # if user_id in param is guest (a guest cannot clone projects), so we replace sshkey for clone project into vm
        # ! no good for security reason. TODO: better to replace with generic key specific for the project
        user_vm = User.find(params[:vm][:user_id])
        user_vm.copy_sshkey_modem(@user.email) if user_vm.guest?

        @vm = Vm.new(vm_params)

        # Json response (json error if issue occurs)
        respond_to do |format|
          if @vm.save
            format.json { render json: Vm.find(@vm.id), status: 200 }
          else
            format.json { render json: @vm.errors, status: :unprocessable_entity }
          end
        end
      end

      # Create a new vm request in short way
      def create_short
        # if user_id in param is guest (a guest cannot clone projects), so we replace sshkey for clone project into vm
        # ! no good for security reason. TODO: better to replace with generic key specific for the project
        user_vm = User.find(params[:vm][:user_id])
        user_vm.copy_sshkey_modem(@user.email) if user_vm.guest?

        @vm = Vm.new(vm_params)

        # Json response (json error if issue occurs)
        respond_to do |format|
          if @vm.save
            @vm.init_defaulturis
            @vm.boot
            format.json { render json: Vm.find(@vm.id), status: 200 }
          else
            format.json { render json: @vm.errors, status: :unprocessable_entity }
          end
        end
      end

      # boot the vm or update user !
      def update
        if @vm.nova_id.nil?
          @vm.boot
        else
          @vm.change_user(params[:vm][:user_id]) if @user.lead?
        end

        # Json output
        respond_to do |format|
          format.json { render json: @vm, status: 200 }
        end
      end

      # Boot vm
      def boot
        @vm.boot
        # Json output
        respond_to do |format|
          format.json { render json: @vm, status: 200 }
        end
      end

      # Toggle auth parameter
      def toggleauth
        @vm.toggleauth
        render nothing: true
      end

      # Toggle isht parameter
      def toggleht
        @vm.toggleht
        render nothing: true
      end

      # Toggle isci parameter
      def toggleci
        @vm.toggleci
        render nothing: true
      end

      # Toggle isbackup parameter
      def togglebackup
        @vm.togglebackup
        render nothing: true
      end

      # Toggle prod parameter
      def toggleprod
        @vm.toggleprod
        render nothing: true
      end

      # Toggle cached parameter
      def togglecached
        @vm.togglecached
        render nothing: true
      end

      # Details one vm properties
      def show
        @vm.init_vnc_url
        # Json output
        respond_to do |format|
          format.json { render json: @vm, status: 200 }
        end
      end

      # Details one vm properties associated with a commit
      def show_by_user_commit
        @vm = Vm.find_by_user_commit(params[:user_id], params[:commit])

        # Json output
        respond_to do |format|
          format.json { render json: @vm, status: 200 }
        end
      end

      # List vms for one user
      def show_by_user
        @vms = Vm.find_by_user_id(params[:user_id])

        # Json output
        respond_to do |format|
          format.json { render json: @vms, status: 200 }
        end
      end

      # Stop and destroy a vm
      def destroy
        # ensute we have permission to destroy the vm
        if  @user.vms.any? { |v| v.id == @vm.id } ||
            @user.lead? && @vm.project.vms.any? { |v| v.id == @vm.id && !@vm.user.admin? } ||
            @user.admin?

            @vm.destroy
            # Json output
            respond_to do |format|
              format.json { head :no_content }
            end
        else

          # Json output
          respond_to do |format|
            format.json { head :no_content, status: 403 }
          end
        end
      end

      # Compute build time and update status field
      def setupcomplete
        @vm = Vm.find_by(name: params[:name])
        @vm.setupcomplete if (@vm)
        render nothing: true
      end

      # Update vm password
      def resetpassword
        @vm = Vm.find_by(name: params[:name])
        @vm.reset_password(params[:password]) if (@vm)
        render nothing: true
      end

      # Check status, get 200 if vm is running
      def check_status
        (@vm.status > 1) ? (codestatus = 200) : (codestatus = 410)
        render plain: @vm.buildtime, status: codestatus
      end

      # Execute gitpull cmd into vm
      def gitpull
        ret = @vm.gitpull
        render plain: ret[:message], status: ret[:status]
      end

      # Execute display of postinstall cmd into vm
      def postinstall_display
        ret = @vm.postinstall_display
        render plain: ret[:message], status: ret[:status]
      end

      # Execute postinstall cmd into vm
      def postinstall
        ret = @vm.postinstall
        render plain: ret[:message], status: ret[:status]
      end

      # Display current logs for the vm
      def logs
        ret = @vm.logs
        render plain: ret[:message], status: ret[:status]
      end

      # Refresh commit id for vm
      def refreshcommit
        @vm = Vm.find_by(name: params[:name])
        @vm.refreshcommit(params[:commit_id])
        render nothing: true
      end

      private

      # check if ci is enabled for lock mecanism
      def check_ci
        ncp = 0
        if @vm.is_ci
          @vm.toggleci(false)
          # wait max 10min to let ci finish his work
          while @vm.checkci do
            break if ncp == 5
            sleep(120)
            ncp += 1
          end
          @vm.clearci
        end

        return true
      end

      # reload ci if enabled for lock mecanism
      def reload_ci
        @vm.reload
        @vm.generate_hiera if @vm.is_ci
      end

      # Use callbacks to share common setup or constraints between actions.
      def set_vm
        @vm = Vm.find(params[:id])
      end

      # ensure that only admin, lead or hisself can execute action
      def check_me
        isme = false
        if @user.lead?
          isme = @user.projects.any? { |project| project.id == @vm.project.id }
        else
          isme = (@user.id == @vm.user.id)
        end

        # only admins can make changes on admins vms
        isme = false if @vm.user.admin? && !@user.admin?

        raise Exceptions::NextDeployException.new("Access forbidden for this user") unless isme
      end

      # Use callbacks to share common setup or constraints between actions.
      def set_project
        @vm = Project.find(params[:project_id])
      end

      # change ember parameter name for well rails relationships
      # HACK: ugly method
      def ember_to_rails
        params_p = params[:vm]

        params_p[:user_id] ||= params_p[:user]
        params_p[:project_id] ||= params_p[:project]
        params_p[:systemimage_id] ||= params_p[:systemimage]
        params_p[:vmsize_id] ||= params_p[:vmsize]
        params_p[:commit_id] ||= params_p[:commit]
        params_p[:techno_ids] ||= params_p[:technos]

        params_p.delete(:created_at)
        params_p.delete(:nova_id)
        #params_p.delete(:name)
        params_p.delete(:floating_ip)
        params_p.delete(:user)
        params_p.delete(:project)
        params_p.delete(:systemimage)
        params_p.delete(:commit)
        params_p.delete(:vmsize)
        params_p.delete(:technos)
        params_p.delete(:vnc_url)
        params_p.delete(:termpassword)
        params_p.delete(:status)

        # force auth if we are not an admin user
        #params_p[:is_auth] = true unless @user.admin?

        params[:vm] = params_p
      end

      # Never trust parameters from the scary internet, only allow the white list through.
      def vm_params
        params.require(:vm).permit(:systemimage_id, :user_id, :commit_id, :project_id, :vmsize_id, :name, :is_auth, :htlogin, :htpassword, :layout, :is_prod, :is_cached, :is_ht, :is_ci, :techno_ids => [])
      end
    end
  end
end
