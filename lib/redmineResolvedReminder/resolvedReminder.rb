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
    
    # Get title, email addr of assigned-to person, links to watchers of the issue
    # (should we also email the originator, if different?)
    def processIssue(issue)
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
      unless issue.watcher_user_ids.nil?
        @watcherIssueSet[issue.id] = User.where(id: issue.watcher_user_ids)
      end
    end

    def collectIssues
      # retrieve list of issues in "Resolved" state
      # for each issue, get title, email addr of assigned-to person
      # (should we also email the originator, if different?)
      status = IssueStatus.find_by(name: "Resolved")
      @log.debug "Status: #{status.name} (#{status.id})"
      Issue.where(status: status).each do |issue|
        processIssue(issue)
      end
      
      # Similar thing for issues that are in the active state but the last
      # update was more than 60 days ago.
      lowerbound = Date.new(2000, 1, 1)
      cutoff = Date.today - 60
      status = IssueStatus.find_by(name: "Active")
      Issue.where(status: status, updated_on: lowerbound..cutoff).each do |issue|
        processIssue(issue)
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
        subject = "Resolved/inactive issues: #{@issList.length}"
        mailReport(subject, body, @email)
      end

      # This clause sends the summary report to the Redmine admins.
      if !(@userIssueSet.empty? && @orphanIssueSet.empty?)
        template = loadTemplate("report.txt.erb")
        renderer = ERB.new(template,nil,">")
        body = renderer.result(binding)
        subject = "Resolved/inactive issue summary for #{@date}"
        RECEIVE_OVERVIEW.each do |username|
          @email = User.find_by(login: username).email_address.address
          mailReport(subject, body, @email)
        end
      end
    end

    def mailReport(subjectLine, text, recip)
      mailhost = Redmine::Configuration['email_delivery']['smtp_settings'][:address]
      mailport = Redmine::Configuration['email_delivery']['smtp_settings'][:port]
      maildomain = Redmine::Configuration['email_delivery']['smtp_settings'][:domain]
      opts = {address: mailhost,
              port: mailport,
              domain: maildomain,
              authentication: "plain",
              tls: false,
              enable_starttls_auto: false}
      Mail.defaults do
        delivery_method :smtp, opts
      end
      Mail.deliver do
        from    "resolvedReport@#{Socket.gethostname}"
        to      recip
        subject subjectLine
        body    text
      end
    end

    def run
      @userIssueSet = {}
      @watcherIssueSet = {}
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
