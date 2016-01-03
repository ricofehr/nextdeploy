module Exceptions
  # The head of exception class for the project
  #
  # @author Eric Fehr (ricofehr@nextdeploy.io, github: ricofehr)
  class NextDeployException < Exception
    attr_reader :message

    # Constructor.
    #
    # @param msg [String] message to log
    def initialize(msg=nil)
      @message = msg
    end

    # Log message and exit (critical exception)
    #
    # No params
    # No return
    def log_e
      log
      exit
    end

    # Log message
    #
    # No params
    # No return
    def log
      Rails.logger.warn @message
    end
  end

  # Class for openstack api exception
  class OSApiException < NextDeployException; end
  # Class for gitlab api exception
  class GitlabApiException < NextDeployException; end
end