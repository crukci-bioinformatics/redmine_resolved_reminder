require "logger"
require "mail"
require "socket"

#require "redmineResolvedReminder/constants"
require File.expand_path(File.dirname(__FILE__)+'/../redmineResolvedReminder/constants')

#$: << RedmineResolvedReminder::REDMINE_HOME + "/config"
#$: << RedmineResolvedReminder::REDMINE_HOME + "/app/models"

#require "boot"
#require RedmineResolvedReminder::APP_PATH

module RedmineResolvedReminder
  class ResolvedReminder
    include Constants

    def initialize(args)
      @testMode = args[:test_mode]
      Rails.application.require_environment!
      logSetup
      @log.debug "Mode: #{@testMode ? "test" : "normal"}"
    end

    def logSetup
      @log = Logger.new(STDERR)
      @log.level = @testMode ? Logger::DEBUG : Logger::INFO
    end

    def collectIssues
      # retrieve list of issues in "Resolved" state
      # for each issue, get title, email addr of assigned-to person
      # (should we also email the originator, if different?)
      status = IssueStatus.find_by(name: "Resolved")
      @log.debug "Status: #{status.name} (#{status.id})"
      Issue.where(status: status).each do |issue|
        assn = issue.assigned_to
        orig = issue.author
        if assn.nil? || assn.status != 1 # '1' is 'active', '3' is 'disabled'
          if orig.nil? || orig.status != 1
            receiver = nil
          else
            receiver = orig
          end
        else
          receiver = assn
        end
        if receiver.nil?
          @orphanIssueSet << issue
        else
          target = receiver.email_address.address
          if ! @userIssueSet.has_key?(target)
            @userIssueSet[target] = []
            @userLoginSet[target] = receiver.login
          end
          @userIssueSet[target] << issue
        end
      end
    end

    def loadTemplate(fn)
      template_path = File.expand_path("../../extra/redmineResolvedReminder",File.dirname(__FILE__))

      path = File.join(template_path,fn)
      fd = File.open(path)
      template = fd.read
      fd.close
      return template
    end

    def report_issues
      template = loadTemplate("report.txt.erb")
      @date = Date.today.iso8601
      renderer = ERB.new(template,nil,">")
      body = renderer.result(binding)
      STDOUT.write(body)
    end

    def email_issues
      template = loadTemplate("email.txt.erb")
      @date = Date.today.iso8601
      @userIssueSet.each do |email,issues|
        @email = email
        @issList = issues
        renderer = ERB.new(template,nil,">")
        body = renderer.result(binding)
        mailReport(body,@email,issues.length)
      end
      # this next clause covers the case where Rory or Matt has no assigned
      # issues, but they should still receive the orphans if any.
      if @orphanIssueSet.length > 0
        RECEIVE_ORPHANS.each do |username|
          if ! @userLoginSet.has_value?(username)
            @email = User.find_by(login: username).email_address.address
            @userLoginSet[@email] = username
            @issList = []
            renderer = ERB.new(template,nil,">")
            body = renderer.result(binding)
            mailReport(body,@email,@issList.length)
          end
        end
      end
    end

    def mailReport(text,recip,count)
      opts = {address: "10.20.221.99",
              port: 25,
              domain: "cruk.cam.ac.uk",
              authentication: "plain",
              tls: false,
              enable_starttls_auto: false}
      Mail.defaults do
        delivery_method :smtp, opts
      end
      Mail.deliver do
        from    "resolvedReport@#{Socket.gethostname}"
        to      recip
        subject "resolved issues: #{count}"
        body    text
      end
    end

    def run
      @userIssueSet = {}
      @userLoginSet = {}
      @orphanIssueSet = []
      collectIssues
      if @testMode
        report_issues
      else
        email_issues
      end
    end
  end
end
