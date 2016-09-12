module API
  module V1
    # Uri controller for the rest API (V1).
    #
    # @author Eric Fehr (ricofehr@nextdeploy.io, github: ricofehr)
    class UrisController < ApplicationController
      # Hook who set uri object
      before_action :set_uri, only: [:show, :update, :destroy, :import, :export, :npm, :mvn, :nodejs, :reactjs, :composer, :logs, :drush, :sfcmd, :clearvarnish, :script, :listscript]
      # Check user right for avoid no-authorized access
      before_action :check_me, only: [:create, :destroy, :update, :import, :export, :npm, :mvn, :nodejs, :reactjs, :composer, :logs, :drush, :sfcmd, :clearvarnish, :script, :listscript]
      # Format ember parameters into rails parameters
      before_action :ember_to_rails, only: [:create, :update]
      # Hook who check ci right before tool action
      before_action :check_ci, only: [:import, :export, :npm, :mvn, :nodejs, :reactjs, :composer, :drush, :sfcmd, :script, :listscript]
      # Hook who reload ci right after tool action
      after_action :reload_ci, only: [:import, :export, :npm, :mvn, :nodejs, :reactjs, :composer, :drush, :sfcmd, :script, :listscript]

      # List all uris
      def index
        # select only objects allowed by current user
        if @user.admin?
          @uris = Uri.all
        else
          if @user.lead?
            projects = @user.projects
            if projects
              @uris = projects.flat_map(&:vms).uniq.flat_map(&:uris)
            end
          else
            @uris = @user.vms.flat_map(&:uris)
          end
        end

        # Json output
        respond_to do |format|
            format.json { render json: @uris || [], status: 200 }
        end
      end

      # Details about one uri
      def show
        # Json output
        respond_to do |format|
          format.json { render json: @uri, status: 200 }
        end
      end

      # Create a new uri
      def create
        @uri = Uri.create(uri_params)

        # Json output
        respond_to do |format|
          if @uri
            format.json { render json: @uri, status: 200 }
          else
            format.json { render json: @uri.errors, status: :unprocessable_entity }
          end
        end
      end

      # Apply changes about one uri
      def update
        # Json output
        respond_to do |format|
          if @uri.update(uri_params)
            format.json { render json: @uri, status: 200 }
          else
            format.json { render json: @uri.errors, status: :unprocessable_entity }
          end
        end
      end

      # Execute npm cmd into vm
      def npm
        ret = @uri.npm
        render plain: ret[:message], status: ret[:status]
      end

      # Rebuild nodejs app
      def nodejs
        ret = @uri.nodejs
        render plain: ret[:message], status: ret[:status]
      end

      # Rebuild reactjs app
      def reactjs
        ret = @uri.reactjs
        render plain: ret[:message], status: ret[:status]
      end

      # Execute mvn cmd into vm
      def mvn
        ret = @uri.mvn
        render plain: ret[:message], status: ret[:status]
      end

      # Execute composer cmd into vm
      def composer
        ret = @uri.composer
        render plain: ret[:message], status: ret[:status]
      end

      # Display current logs for the vm
      def logs
        ret = @uri.logs
        render plain: ret[:message], status: ret[:status]
      end

      # Execute drush cmd into vm
      def drush
        ret = @uri.drush params[:command]
        render plain: ret[:message], status: ret[:status]
      end

      # Execute custom bash script
      def script
        # secure command parameter
        params[:command] = params[:command].gsub('..', '').gsub(';', '');

        ret = @uri.script(params[:command].split(',')[0], params[:command].split(',')[1])
        render plain: ret[:message], status: ret[:status]
      end

      # List custom bash script
      def listscript
        ret = @uri.listscript
        render plain: ret[:message]
      end

      # Execute symfony command into vm
      def sfcmd
        env = @uri.vm.is_prod ? 'prod' : 'dev'
        command = params[:command]
        messages = []
        rstatus = 200

        if command == 'cc'
          ret = @uri.sfcmd "assets:install --symlink --env=#{env}"
          messages.push ret[:message]
          ret = @uri.sfcmd "assetic:dump --env=#{env}"
          messages.push ret[:message]
          ret = @uri.sfcmd "cache:clear --env=#{env}"
          messages.push ret[:message]
          rstatus = ret[:status]
        elsif command == 'doctrine'
          ret = @uri.sfcmd "doctrine:schema:update --force --env=#{env}"
          messages.push ret[:message]
          rstatus = ret[:status]

          ret = @uri.sfcmd "assets:install --symlink --env=#{env}"
          messages.push ret[:message]

          ret = @uri.sfcmd "assetic:dump --env=#{env}"
          messages.push ret[:message]

          ret = @uri.sfcmd "cache:clear --env=#{env}"
          messages.push ret[:message]
        elsif command == 'migration'
          ret = @uri.sfcmd "doctrine:migrations:migrate --env=#{env}"
          messages.push ret[:message]
          rstatus = ret[:status]

          ret = @uri.sfcmd "assets:install --symlink --env=#{env}"
          messages.push ret[:message]

          ret = @uri.sfcmd "assetic:dump --env=#{env}"
          messages.push ret[:message]

          ret = @uri.sfcmd "cache:clear --env=#{env}"
          messages.push ret[:message]
        else
          ret = @uri.sfcmd "#{params[:command]} --env=#{env}"
          messages.push ret[:message]
        end

        render plain: messages.join("\n"), status: rstatus
      end

      # clear varnish cache
      def clearvarnish
        ret = @uri.clearvarnish
        render plain: ret[:message], status: ret[:status]
      end

      # Execute datas import into vm
      def import
        ret = @uri.import
        render plain: ret[:message], status: ret[:status]
      end

      # Execute datas export into vm
      def export
        ret = @uri.export(params[:branchs])
        render plain: ret[:message], status: ret[:status]
      end

      # Destroy one uri
      def destroy
        @uri.destroy

        # Json output
        respond_to do |format|
          format.json { head :no_content }
        end
      end

      private
       # check right about admin user
        def only_create
          if ! @user.is_project_create
            raise Exceptions::GitlabApiException.new("Access forbidden for this user")
          end

          # only admin can change anyone project
          if ! @user.admin? && params[:owner_id] && params[:owner_id] != @user.id
            raise Exceptions::GitlabApiException.new("Access forbidden for this user")
          end

          true
        end

        # ensure that only admin, lead or hisself can execute action
        def check_me
          isme = false
          vm = nil

          if @uri
            vm = @uri.vm
          elsif params[:uri][:vm]
            vm = Vm.find(params[:uri][:vm])
          else
            return false
          end

          if @user.lead?
            isme = @user.projects.any? { |project| project.id == vm.project.id }
          else
            isme = (@user.id == vm.user.id)
          end

          # only admins can make changes on admins vms
          isme = false if vm.user.admin? && !@user.admin?

          raise Exceptions::NextDeployException.new("Access forbidden for this user") unless isme
        end

        # check if ci is enabled for lock mecanism
        def check_ci
          vm = @uri.vm
          ncp = 0

          if vm.is_ci
            vm.toggleci(false)
            # wait max 10min to let ci finish his work
            while vm.checkci do
              break if ncp == 5
              sleep(120)
              ncp += 1
            end
            vm.clearci
          end

          return true
        end

        # reload ci if enabled for lock mecanism
        def reload_ci
          vm = @uri.vm
          vm.reload
          vm.generate_hiera if vm.is_ci
        end

        # Use callbacks to share common setup or constraints between actions.
        def set_uri
          @uri = Uri.find(params[:id])
        end

        # change ember parameter name for well rails relationships
        # houuuu que c est moche
        def ember_to_rails
          params_p = params[:uri]

          params_p[:vm_id] ||= params_p[:vm]
          params_p[:framework_id] ||= params_p[:framework]
          params_p.delete(:vm)
          params_p.delete(:framework)
          params[:uri] = params_p
        end

        # Never trust parameters from the scary internet, only allow the white list through.
        def uri_params
          params.require(:uri).permit(:absolute, :path, :aliases, :envvars, :vm_id, :framework_id, :port, :ipfilter, :customvhost, :is_sh)
        end
    end
  end
end
