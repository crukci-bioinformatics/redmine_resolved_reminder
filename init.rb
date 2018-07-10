require 'redmine'
require 'redmineResolvedReminder/constants'
require 'redmineResolvedReminder/resolvedReminder'

Redmine::Plugin.register :resolved_reminder do
  name 'Resolved Reminder plugin'
  author 'Gord Brown'
  description 'Remind users of issues that are in status Resolved that should be checked or closed'
  version RedmineResolvedReminder::Constants::VERSION
  url 'https://github.com/gdbzork/redmine_resolved_reminder'
  author_url 'http://gdbrown.org/blog/'
end
