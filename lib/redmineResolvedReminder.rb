require "logger"
require "redmineResolvedReminder/constants"

$: << RedmineResolvedReminder::REDMINE_HOME + "/config"
$: << RedmineResolvedReminder::REDMINE_HOME + "/app/models"

require "boot"
require RedmineResolvedReminder::APP_PATH

module RedmineResolvedReminder
  class RedmineResolvedReminder

    def initialize(args)
      @testMode = args[:test_mode]
      Rails.application.require_environment!
      logSetup
    end

    def logSetup
      @log = Logger.new(STDERR)
      @log.level = Logger::DEBUG
    end

    def run()
      # retrieve list of issues in "Resolved" state
      # for each issue, get title, email addr of assigned-to person
      # (should we also email the originator, if different?)
      status = IssueStatus.find_by(name: "Resolved")
      puts "Status: #{status.name} (#{status.id})"
    end
  end
end
