require "optparse"

#require "redmineResolvedReminder/resolvedReminder"
#require "redmineResolvedReminder/constants"
require File.expand_path(File.dirname(__FILE__)+'/../redmineResolvedReminder/constants')
require File.expand_path(File.dirname(__FILE__)+'/../redmineResolvedReminder/resolvedReminder')

namespace :redmine do
  namespace :resolved_reminder do
    include RedmineResolvedReminder::Constants

    desc "Remind users of issues in status 'Resolved', which should be closed or reassigned/reopened."
    task :checkResolved => :environment do
      args = {test_mode: false}
      begin
        OptionParser.new do |o|
          o.banner = "Usage: #{File.basename($0)} [options]"
          o.on("-t","--test","test mode: do not send emails") {|t| args[:test_mode] = true}
          o.on("-v","--version","show version of the gem") do
            puts "version #{RedmineResolvedReminder::Constants::VERSION}"
            exit
          end
        end.parse!
      rescue OptionParser::ParseError => pe
        STDERR.puts pe.message
        exit
      end
      reminder = RedmineResolvedReminder::ResolvedReminder.new(args)
      reminder.run()
    end
  end
end
