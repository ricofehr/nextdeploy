module Exceptions
  # The head of exception class for the project
  #
  # @author Eric Fehr (eric.fehr@publicis-modem.fr, github: ricofehr)
  class MvmcException < Exception
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
      puts @message
    end
  end

  # Class for openstack api exception
  class OSApiException < MvmcException; end
  # Class for gitlab api exception
  class GitlabApiException < MvmcException; end
end